require 'XDatabase.rb'

id="mpmwjphuiirkqlnp" #irgendwas in Köln
#result = fetch_POIs_from_SPARQL(id)
#puts result

db = XDatabase.new("stevenmohr.de", 1984, "admin", "admin")
result = db.fetch_POIs_from_SPARQL(id,"database2")
db.close
puts result

#id="blah"
#id="mpmwjphuiirkqlnp"
#points =  get_waypoints(id)
#puts points
#coords = create_coord_array(points,10)
#result = get_POIs(coords)
#puts result 


#command to delete nodes:
#for $x track
#where $x/uid="mpmwjphuiirkqlnp"
#return (delete node $x/pois)