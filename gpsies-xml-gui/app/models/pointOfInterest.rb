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
	result = []
	dbconfig =  Gpsies::CONFIG[:database]
	session = BaseXClient::Session.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
	session.execute("open #{dbconfig[:database]}")

    begin
	  input = 'for $x in track where $x/uid="'+id+'" return $x/pois/poi'
	  query = session.query(input)

	  t = query.next
      
      if t.nil?
        #invoke SparqlClient
        sparclclient = Sparql::SparqlClient.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
        sparclclient.execute("open #{dbconfig[:database]}")
        
        pois = sparclclient.fetch_POIs_from_SPARQL(id)

        sparclclient.close
      end
	  query = session.query(input)
	  t = query.next

	  while !t.nil?
	    xml = XmlSimple.xml_in(t)
		
		tweet = Twitter.search("#{xml['title'].first}", :lang => "de", :rpp => 1).first
		if !tweet.nil?
		  tweet = tweet.text
		  result.push( PointOfInterest.new(title: xml['title'].first,
			    link: xml['link'].first, tweet: tweet))
		else
	      result.push( PointOfInterest.new(title: xml['title'].first,
			    link: xml['link'].first, tweet: "Keine Tweets zu diesem POI"))
		end
	    t = query.next
	  end
      
	  query.close
    rescue Exception => e
      puts e
    ensure    
      session.close
    end
	
    result
  end
	
end
