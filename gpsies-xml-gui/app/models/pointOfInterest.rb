require 'basex/BaseXClient'
require 'xmlsimple'
require "../config/basex.rb"
require 'sparql/SparqlClient.rb'

class PointOfInterest
  attr_reader :title, :link
  
  def initialize(params = {})
	@title = params[:title]
	@link = params[:link]
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
        puts pois

        sparclclient.close
        #TODO: put pois in  result
        result = Array.new

      else
        result = Array.new
        while !t.nil?
          xml = XmlSimple.xml_in(t)


          result.push( PointOfInterest.new(title: xml['title'].first,
                  link: xml['link'].first))
          t = query.next
        end
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
