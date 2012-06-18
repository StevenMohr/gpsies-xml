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
	
	def self.all()
		a = Array.new
		i = 0
		while i < 100
			r = rand(100)
			a.push( Track.new ( { description: "Ein Objekt", track_length: r, title: "Track Laenge: " } ) )
			i += 1
		end	
# 		[ Track.new( description: "Es klappt! :)", track_length: 123, title: "Testt!!") , Track.new]
		return a
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
