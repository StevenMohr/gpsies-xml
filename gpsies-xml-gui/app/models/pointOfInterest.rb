require 'basex/BaseXClient'
require 'xmlsimple'

class PointOfInterest
  attr_reader :title, :link
  
  def initialize(params = {})
	@title = params[:title]
	@link = params[:link]
  end

  def self.all(id)
    session = BaseXClient::Session.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
    session.execute("open database2")

    begin
	  input = 'for $x in track where $x/uid="'+id+'" return $x/pois/poi'
	  query = session.query(input)

	  t = query.next
		
	  result = Array.new
	  while !t.nil?
	    xml = XmlSimple.xml_in(t)


	    result.push( PointOfInterest.new(title: xml['title'].first,
				 link: xml['link'].first))
	    t = query.next
	  end
	  query.close
    end
    session.close
    return result
  end
	
end
