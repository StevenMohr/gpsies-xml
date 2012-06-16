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
		[ Track.new( description: "Es klappt! :)", track_length: 123, title: "Testt!!") , Track.new ]
	end

	def self.find(params)
	end
end
