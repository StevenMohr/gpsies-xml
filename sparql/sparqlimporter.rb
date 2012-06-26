require './XDatabase.rb'
require '../config/basex.rb'

#id="mpmwjphuiirkqlnp" #irgendwas in Köln
#id="gqbytnxxihdunukf" # irgendwas in Potsdam
begin
  dbconfig =  Gpsies::CONFIG[:database]
  
  session = BaseXClient::Session.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
  session.execute("open #{dbconfig[:database]}")

  queryString = "for $x in track return $x/uid/text()"
  query = session.query(queryString)
  
  sparqlclient = XDatabase.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
  sparqlclient.execute("open #{dbconfig[:database]}")

  uid = query.next
  while !uid.nil?
    queryString2 = "for $x in track where $x/uid=\"#{uid}\" return $x/pois"
    query2 = session.query(queryString2)
    
    pois = query2.next
    
    puts uid
    
    if pois.nil?
      sparqlclient.fetch_POIs_from_SPARQL(uid)
    end

     
     
     uid = query.next
  end
  
  sparqlclient.close
  query.close

  session.close
rescue Exception => e
   puts e
end 
#command to delete nodes:
#xquery for $x in track where $x/uid="caaivlogftcnpupm" return (delete node $x/pois)
#xquery for $x in track where $x/uid="gqbytnxxihdunukf" return (delete node $x/pois)

#xquery for $x in track where $x/uid="gqbytnxxihdunukf" return $x/pois

