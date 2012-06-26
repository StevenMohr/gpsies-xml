require 'basex/BaseXClient'
require 'xmlsimple'
require "../config/basex.rb"

class Track
	attr_reader :uid, :title, :description, :created_date, :track_length

	def initialize (params = {})
		@uid = params[:uid]
		@title = params[:title]
		@description = params[:description]
		begin
			@created_date = DateTime.parse params[:created_date]
		rescue
			@created_date = DateTime.now
		end

		@track_length = params[:track_length].to_f
	end

	def pois
	  PointOfInterest.all(@uid)
	end

	def self.select(params = {})
		uid = params[:uid]
		offset = params[:offset] || 0
		count = params[:count] || 1
		keywords = params[:keywords] || []
		order_by = params[:order_by] || [[:created_date, :descending]]
		
		where_clauses = []
		if uid then where_clauses << %{$track/uid = "#{uid}"} end
		keywords.each do |keyword|
			where_clauses << %{(
				contains($track/title, "#{keyword}") or
				contains($track/description, "#{keyword}")
			)}
		end
		
		order_by_clauses = []
		order_by.each do |criterion|
			column, order = *criterion
			clause_column = case column
				when :title
					'$track/title'
				when :description
					'$track/description'
				when :track_length
					'number($track/trackLength)'
				when :created_date
					'$track/createdDate'
			end
			clause_order = case order
				when :ascending
					'ascending'
				when :descending
					'descending'
				else
					''
			end
			order_by_clauses << "#{clause_column} #{clause_order}"
		end
			
		q = %{
			let $tracks := (
				for $track in track
				#{
					if where_clauses.empty? then ''
					else 'where ' + where_clauses.join(' and ') end
				}
				#{
					if order_by_clauses.empty? then ''
					else 'order by ' + order_by_clauses.join(', ') end
				}
				return $track
			)
			for $track in subsequence($tracks, #{offset + 1}, #{count})
			return
				<track>
					{$track/uid}
					{$track/title}
					{$track/description}
					{$track/trackLength}
					{$track/createdDate}
				</track>
		}
		query(q)
	end
	
	def self.find(id)
		result = select(uid: id, count: 1)
		if result
			result.first 
		else
			nil
		end
	end

	protected
	def self.query(str)
		dbconfig =  Gpsies::CONFIG[:database]
		session = BaseXClient::Session.new(
			dbconfig[:host],
			dbconfig[:port],
			dbconfig[:user],
			dbconfig[:pass]
		)
		result = []
		begin
			session.execute("open #{dbconfig[:database]}")
			query = session.query(str)
			return [] unless query
			begin
				while query.more
					t = query.next
					xml = XmlSimple.xml_in(t)
					result << Track.new(
						description: xml['description'].first,
						track_length: xml['trackLength'].first,
						title: xml['title'].first,
						uid: xml['uid'].first,
						created_date: xml['createdDate'].first
					)
				end
			ensure
				query.close
			end
		rescue # discard exception ;)
		ensure
			session.close
		end
		result
	end
end
