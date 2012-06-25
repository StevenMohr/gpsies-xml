require 'basex/BaseXClient'
require 'xmlsimple'
require "../config/basex.rb"
require 'sparql/SparqlClient.rb'
require 'twitter'

class PointOfInterest
  attr_reader :title, :link, :tweet
  
  def initialize(params = {})
	@title = params[:title]
	@link = params[:link]
	@tweet = params[:tweet]
  end

  def self.all(id)
    dbconfig =  Gpsies::CONFIG[:database]
    session = BaseXClient::Session.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
    session.execute("open database2")

	
    begin
	  input = 'for $x in track where $x/uid="'+id+'" return $x/pois/poi'
	  query = session.query(input)

	  t = query.next
      
      if t.nil?
        #invoke SparqlClient
        sparclclient = Sparql::SparqlClient.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
        sparclclient.execute("open database2")
        
        pois = sparclclient.fetch_POIs_from_SPARQL(id)
        # puts pois

        sparclclient.close
		# xml = XmlSimple.xml_in(pois)
		# puts xml.to_s
		# result = Array.new
		# xml['pois'].each { |poi|
		#	result.push( PointOfInterest.new(title: poi['title'].first,
        #          link: poi['link'].first))
		# }
        #TODO: put pois in  result
      end
	  query = session.query(input)
	  t = query.next
      
	  result = Array.new
	  while !t.nil?
	    xml = XmlSimple.xml_in(t)
		
		tw = Twitter.search("#{xml['title'].first}", :lang => "de", :rpp => 1).first
		if !tw.nil?
		  puts tw.text
		  result.push( PointOfInterest.new(title: xml['title'].first,
			    link: xml['link'].first, tweet: Twitter.search("#{xml['title'].first}", :lang => "de", :rpp => 1).first.text))
		else
	      result.push( PointOfInterest.new(title: xml['title'].first,
			    link: xml['link'].first, tweet: "Keine Tweets zu diesem POI"))#Twitter.search("#{xml['title'].first}", :lang => "de", :rpp => 1).first.text))
		end
	    t = query.next
	  end
      
	  query.close
    rescue Exception => e
      puts e
      result = Array.new
    ensure    
      session.close
    end
    
    return result
  end
	
end
