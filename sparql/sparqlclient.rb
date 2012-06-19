require 'XDatabase.rb'

#id="mpmwjphuiirkqlnp" #irgendwas in Köln
#id="gqbytnxxihdunukf" # irgendwas in Potsdam

db = XDatabase.new("stevenmohr.de", 1984, "admin", "admin")
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
#command to delete nodes:
#xquery for $x in track where $x/uid="caaivlogftcnpupm" return (delete node $x/pois)
#xquery for $x in track where $x/uid="gqbytnxxihdunukf" return (delete node $x/pois)