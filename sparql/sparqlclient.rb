require 'rubygems'
require 'sparql/client'

require 'xbaseaccess.rb'
require 'queryhelper.rb'

#for a given ID gets waypoints from database,
#fetches POIs from sparql
#inserts them into our XML-database
#returns POIs as XML string
def fetch_POIs_from_SPARQL(id)
  
  points = get_waypoints(id)
  
  coords = create_coord_array(points,10)
  
  result = get_POIs(coords)
  
  if !result.nil?
    res = insert_pois(id, result)
    #TODO: define what happens if insert into database is not successful
    
    pois = "<pois>#{result}</pois>"
  end 
end
=begin
#nullrequest
puts fetch_POIs_from_SPARQL("1")

#proper request
id = "blah"
start = Time.now
puts fetch_POIs_from_SPARQL(id)
puts (Time.now - start) *1000
=end

id="mpmwjphuiirkqlnp" #irgendwas in Köln
result = fetch_POIs_from_SPARQL(id)
puts result
#id="blah"
=begin
points =  get_waypoints(id)
coords = create_coord_array(points,10)
result = get_POIs(coords)
puts result 
=end

#command to delete nodes:
#for $x track
#where $x/uid="mpmwjphuiirkqlnp"
#return (delete node $x/pois)