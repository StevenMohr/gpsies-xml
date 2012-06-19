require 'basex/BaseXClient'
require 'xmlsimple'
class Track
	attr_reader :uid, :title, :description, :created_date, :track_length

	def initialize (params = {})
		@uid = params[:uid]
		@title = params[:title]
		@description = params[:description]
		@created_date = params[:created_date]
		@track_length = params[:track_length]
	end
	def pois
		[PointOfInterest.new("test1"), PointOfInterest.new("test2")]
	end
	
	def _fetchAllTracks 
		session = BaseXClient::Session.new("stevenmohr.de", 1984, "admin", "admin")
		session.execute("open database2")

		begin
			input = "for $x in track return $x"
			query = session.query(input)

			t = query.next
			result = Array.new
			while !t.nil?
#				result += t
				xml = XmlSimple.xml_in(t)
				result.push Track.new (	title: xml['title'],	description: xml['description'],track_length: xml['trackLength'] )
				t = query.next
			end
			# result = query.next

			query.close
		end
		session.close
		return result
	end
	
	def self.all()
 		[ Track.new( description: "Es klappt! :)", track_length: 123, title: "Testt!!") , Track.new]
	end

	def self.find(id)
		Track.new(
			description: "Es klappt! :)",
			track_length: 123,
			title: "Testt!!",
			uid: id.to_s,
			created_date: DateTime.now )
	end




end
