require 'rubygems'
require 'sparql/client'
sparql = SPARQL::Client.new("http://dbpedia.org/sparql")

#takes an array of hashes (latitude-longitude pairs :lat :long)
#and an interval for the points
#returns a SPARQL-Query
def querybuilder(points, interval)
  query = "SELECT DISTINCT ?subject ?label ?abstract ?lat ?long WHERE
    {"
    points.each do |p|
    
      query += " {
        ?subject geo:lat ?lat.
        ?subject geo:long ?long.
        ?subject rdfs:comment ?abstract. 
        ?subject rdfs:label ?label.
        OPTIONAL { ?subject dbpprop:type ?type } 
        FILTER(
        ?lat - #{p[:lat]} <= #{interval} && 
        #{p[:lat]} - ?lat <= #{interval} && 
        ?long - #{p[:long]} <= #{interval} &&
        #{p[:long]} - ?long <= #{interval} && 
        lang(?label) = \"de\" && 
        lang(?abstract) = \"de\"
        && ?type != \"Quarter\"@en
        ).
        "
       query += "} UNION " unless p == points.last
    end
  query += "} }"
end

start = Time.now

coords = Array.new

coords[0] = Hash.new
coords[0][:lat] = 52.5163
coords[0][:long] = 13.3777

coords[1] = Hash.new
coords[1][:lat] = 48.3986
coords[1][:long] = 9.9925

interval = 0.005
queryString = querybuilder(coords, interval)

start = Time.now


query = sparql.query(queryString)

#puts query.inspect

query.each_solution do |solution|
  puts solution[:subject]
  puts solution[:label]
  puts solution[:abstract]
  puts solution[:lat]
  puts solution[:long]
  puts "--------------------------"
end

finish = Time.now
  
puts (finish - start) * 1000.0