require './XDatabase.rb'
require '../config/basex.rb'

#id="mpmwjphuiirkqlnp" #irgendwas in Köln
#id="gqbytnxxihdunukf" # irgendwas in Potsdam
begin
  dbconfig =  Gpsies::CONFIG[:database]
  
  db = XDatabase.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
  db.open("database2")

  id = "caaivlogftcnpupm"
  puts "Fetching POIs for UID #{id}"
  result = db.fetch_POIs_from_SPARQL(id)
  puts result
  puts "------------------"

  id="gqbytnxxihdunukf"
  puts "Fetching POIs for UID #{id}"
  result = db.fetch_POIs_from_SPARQL(id)
  puts result

  db.close
rescue Exception => e
   puts e
end 
#command to delete nodes:
#xquery for $x in track where $x/uid="caaivlogftcnpupm" return (delete node $x/pois)
#xquery for $x in track where $x/uid="gqbytnxxihdunukf" return (delete node $x/pois)