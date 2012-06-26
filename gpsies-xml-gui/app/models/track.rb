require 'basex/BaseXClient'
require 'xmlsimple'
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
		[PointOfInterest.new("test1"), PointOfInterest.new("test2")]
	end
	
	def self.all()
		session = BaseXClient::Session.new("stevenmohr.de", 1984, "admin", "admin")
		session.execute("open database2")

		begin
			input = "for $x in track return <track>{$x/uid}{$x/title}{$x/description}{$x/trackLength}{$x/createdDate}</track>"
			query = session.query(input)

			t = query.next
			result = Array.new
			while !t.nil?
				xml = XmlSimple.xml_in(t)


 				result.push( Track.new(description: xml['description'].first,
									   track_length: xml['trackLength'].first,
									   title: xml['title'].first,
									   uid: xml['uid'].first,
						   			   created_date: xml['createdDate'].first))
				t = query.next
			end
			query.close
		end
		session.close
		return result
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


        if parameters[:id]?
          id = parameters[:id]
        else if parameters[:keyword]?
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


		puts "XXXXX: "+t.to_s

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
end
