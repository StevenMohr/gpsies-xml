require 'net/http'
require 'rexml/document'
#takes an array of hashes (latitude-longitude pairs :lat :long)
#and an interval for the points
#returns a SPARQL-Query
def querybuilder(points, interval)
  query = "SELECT DISTINCT ?subject ?label ?lat ?long WHERE
    {"
    points.each do |p|
    
      query += " {
        ?subject geo:lat ?lat.
        ?subject geo:long ?long.
        ?subject rdfs:label ?label.
        OPTIONAL { ?subject dbpprop:type ?type } 
        FILTER(
        ?lat - #{p[:lat]} <= #{interval} && 
        #{p[:lat]} - ?lat <= #{interval} && 
        ?long - #{p[:long]} <= #{interval} &&
        #{p[:long]} - ?long <= #{interval} && 
        lang(?label) = \"de\" && 
        ?type != \"Quarter\"@en
        ).
        "
       query += "} UNION " unless p == points.last
    end
 
  
  if points.length==0
    query=nil;
  else
     query += "} }"
  end
end

#builds a different query than querybuilder() for the same purpose 

#TODO: test performance of both functions
#querybuilder appears to be wayyyyyyyyyyyyyyyyyyy faster
def querybuilder2(points, interval)
  query = "SELECT DISTINCT ?subject ?label ?lat ?long WHERE
    {
       ?subject geo:lat ?lat.
        ?subject geo:long ?long.
        ?subject rdfs:label ?label.
        OPTIONAL { ?subject dbpprop:type ?type } 
        FILTER( ("
    points.each do |p|
    
      query += "(
        ?lat - #{p[:lat]} <= #{interval} && 
        #{p[:lat]} - ?lat <= #{interval} && 
        ?long - #{p[:long]} <= #{interval} &&
        #{p[:long]} - ?long <= #{interval} )"
  
       query += "||" unless p == points.last
    end
 
  
  if points.length==0
    query=nil;
  else
     query += ") &&
     lang(?label) = \"de\" && 
     ?type != \"Quarter\"@en
        ) .}"
  end
end


#creates an array of hashes (latitude-longitude pairs :lat :long) 
def create_coord_array(result)
   # extract waypoint information
    coords = Array.new
 
    doc = REXML::Document.new(result)
 
    i=0
    doc.elements.each('waypoints/waypoint') do |ele|
      coords[i] = Hash.new
      coords[i][:lat] = ele.attributes["latitude"]
      coords[i][:long] = ele.attributes["longitude"]
      i += 1
    end

=begin
#example coordinates to get more POIs
    coords[i] = Hash.new
    #Coordinates of Ulm Minster 
    coords[i][:lat] = 48.3986
    coords[i][:long] = 9.9925

    # print all coordinates
    coords.each do |c|
      puts "Latitude: #{c[:lat]}, Longitude: #{c[:long]}"
    end
=end
    return coords
end


#for an array of lat-long coords
#fethces POIs from sparql
#returns POIs as XML-string
def get_POIs(coords)
  sparql = SPARQL::Client.new("http://dbpedia.org/sparql")


  interval = 0.005
  #queryString = querybuilder(coords, interval)
  queryString = querybuilder2(coords, interval)

  if queryString
    query = sparql.query(queryString)
    
    result = Array.new
    i = 0
    
    query.each_solution do |solution|
      page = solution[:subject].to_s.split('/').last
      link = "http://en.wikipedia.org/wiki/#{page}"
      result[i] = ""
      result[i] += "<poi>
      <title>#{solution[:label]}</title>
      <link>#{link}</link>
      <location latitutde=\"#{solution[:lat]}\" longitude=\"#{solution[:long]}\" />
      </poi>"
      i += 1
    end

    return result
  else
    puts "No Waypoints found"
    return nil
  end
end