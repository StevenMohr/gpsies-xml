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

	def pois(id)
	  PointOfInterest.all(id)
		#[PointOfInterest.new(title: "test1", link: "test"),
		#   PointOfInterest.new(title: "test2", link: "test")]
	end
	
	def self.all()
		#query("for $x in track return <track>{$x/uid}{$x/title}{$x/description}{$x/trackLength}{$x/createdDate}</track>")
		findAll()
	end
	
	def self.findAll(params = {})
		offset = params[:offset] || 0
		count = params[:count]
		q = <<EOS
let $tracks = track
for $track at $position in $tracks
where
	$position > #{offset}
	#{unless count.nil? then "and $position <= #{offset + count}" end}
return
	<track>
		{$track/uid}
		{$track/title}
		{$track/description}
		{$track/trackLength}
		{$track/createdDate}
	</track>
EOS
		q2 = <<EOS
let $tracks = track
for $track at $position in {
	for $t in $tracks
	order by $t/trackLength
	return $t
}
where
	$position > #{offset}
	#{unless count.nil? then "and $position <= #{offset + count}" end}
return
	<track>
		{$track/uid}
		{$track/title}
		{$track/description}
		{$track/trackLength}
		{$track/createdDate}
	</track>
EOS
		query(q)
	end
	
	def self.find(parameters = {:page => 0, :count => 20})

        if parameters[:page].to_i >= 0
          page = parameters[:page].to_i
        else
          page = 0;
        end

        if parameters[:limit].to_i > 0
          limit = parameters[:limit]
        else
          limit = 20;
        end


        if parameters[:id]
          id = parameters[:id]
        elsif parameters[:keyword]
			keyword = parameters[:keyword]
		end

		session = BaseXClient::Session.new("stevenmohr.de", 1984, "admin", "admin")
        session.execute("open database2")

		begin
			input = 'for $x in track '
            if id?
              input = input+'where $x/uid="'+id+'"'
            else
              if keyword?
                input = input+'where $x/description="'+keyword+'" || title="'+keyword+'"'
              end
            end

          # TODO: here, add limit/offset (pagination support)
            input = input+"return $x"

			puts input
			query = session.query(input)
			t = query.next
			query.close
			session.close
		end


		# puts "XXXXX: "+t.to_s

		if !t.nil?
			xml = XmlSimple.xml_in(t)

			Track.new(description: xml['description'].first,
					  track_length: xml['trackLength'].first,
					  title: xml['title'].first,
					  uid: xml['uid'].first,
					  created_date: xml['createdDate'].first)
		else
			raise "Not found"
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
		session.execute("open database2")
		query = session.query(str)
		result = []
		return nil unless session.ok
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
		query.close
		session.close
		return result
	end
end
