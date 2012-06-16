class Track
	def uid
		"uid"
	end
	def title
		"title"
	end
	def description
		"desc"
	end
	def created_date
		Date.new
	end
	def track_length
		return 123
	end
	def pois
		[PointOfInterest.new("test1"), PointOfInterest.new("test2")]
	end
	
	def self.all()
		[ Track.new, Track.new ]
	end

	def self.find(params)
	end
end
