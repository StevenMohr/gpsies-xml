require './SparqlClient.rb'
require '../config/basex.rb'

begin
  dbconfig =  Gpsies::CONFIG[:database]
  
  session = BaseXClient::Session.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
  session.execute("open #{dbconfig[:database]}")

  queryString = "for $x in track return $x/uid/text()"
  query = session.query(queryString)
  
  sparqlclient = Sparql::SparqlClient.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
  sparqlclient.execute("open #{dbconfig[:database]}")

  uid = query.next
  while !uid.nil?
    queryString2 = "for $x in track where $x/uid=\"#{uid}\" return $x/pois"
    query2 = session.query(queryString2)
    
    pois = query2.next
    
    puts "Importing Track #{uid}"
    
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
ensure
  puts "POI-Import abgeschlossen."
  sparqlclient.close unless sparqlclient.nil?
  query.close unless query.nil?
  session.close unless session.nil?
end

