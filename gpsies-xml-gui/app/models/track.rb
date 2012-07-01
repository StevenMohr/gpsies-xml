require 'basex/BaseXClient'
require 'xmlsimple'
require "../config/basex.rb"
require 'sparql/SparqlClient.rb'
require 'sparql/queryhelper.rb'

class Track
	attr_reader :uid, :title, :description, :created_date, :track_length, :start_point, :end_point, :total_count

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
        @start_point = params[:start_point]
        @end_point = params[:end_point]        
        @total_count = params[:total_count]		
	end
    
    def self.map(uid)
      begin
        dbconfig =  Gpsies::CONFIG[:database]
        sparclclient = Sparql::SparqlClient.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
        sparclclient.execute("open #{dbconfig[:database]}")
      
        waypoints = sparclclient.get_waypoints(uid)
        
        result = []
        result << create_coord_array(waypoints, 1) 
    
      rescue Exception => e
        raise e
      ensure
        sparclclient.close
      end
      result
    end

	# WARNING: input will NOT be sanitized
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
		
    dbconfig =  Gpsies::CONFIG[:database]
	q = %{
             #{dbconfig[:nsdec]}
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
          for $track at $count in subsequence($tracks, #{offset + 1}, #{count})
          return
            <track>
              {$track/uid}
              {$track/title}
              {$track/description}
              {$track/trackLength}
              {$track/createdDate}
              <startpoint><lat>{data($track/waypoints/waypoint[1]/@latitude)}</lat><lng>{data($track/waypoints/waypoint[1]/@longitude)}</lng></startpoint>
              <endpoint><lat>{data($track/waypoints/waypoint[last()]/@latitude)}</lat><lng>{data($track/waypoints/waypoint[last()]/@longitude)}</lng></endpoint>
              {if ($count=1) then <count>{count($tracks)}</count> else ()}
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
      begin
        dbconfig =  Gpsies::CONFIG[:database]
        session = BaseXClient::Session.new(
                    dbconfig[:host],
                    dbconfig[:port],
                    dbconfig[:user],
                    dbconfig[:pass]
                  )
        
        result = []
      
        session.execute("open #{dbconfig[:database]}")
        query = session.query(str)
		return [] unless query
	
		while query.more
          t = query.next
          xml = XmlSimple.xml_in(t)
                    
          if result.empty?
                      #TODO: switch longitude/latitude
            startp = { lng: xml['startpoint'].first['lat'].first, lat: xml['startpoint'].first['lng'].first }
            endp = { lng: xml['endpoint'].first['lat'].first, lat: xml['endpoint'].first['lng'].first }
                      
            result << Track.new(
                        description: xml['description'].first,
                        track_length: xml['trackLength'].first,
                        title: xml['title'].first,
                        uid: xml['uid'].first,
                        created_date: xml['createdDate'].first,
                        start_point: startp,
                        end_point: endp,
                        total_count: xml['count'].first
                      )
          else
            result << Track.new(
                        description: xml['description'].first,
                        track_length: xml['trackLength'].first,
                        title: xml['title'].first,
                        uid: xml['uid'].first,
                        created_date: xml['createdDate'].first,
                      )
          end
        end
      rescue Exception => e
        puts e
      ensure
        query.close
        session.close
      end
		result
    end
end
