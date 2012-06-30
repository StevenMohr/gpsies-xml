require 'net/http'
require 'rexml/document'
#takes an array of hashes (latitude-longitude pairs :lat :long)
#and an interval for the points
#returns a SPARQL-Query
#probably obsolete
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
  #puts points.last
  query = "SELECT DISTINCT ?subject ?label ?lat ?long WHERE
    {
       ?subject geo:lat ?lat.
        ?subject geo:long ?long.
        ?subject rdfs:label ?label.
        OPTIONAL { ?subject dbpprop:type ?type } 
        FILTER( ("
    i=0
    points.each do |p|
      query += "(
        ?lat - #{p[:lat]} <= #{interval} && 
        #{p[:lat]} - ?lat <= #{interval} && 
        ?long - #{p[:long]} <= #{interval} &&
        #{p[:long]} - ?long <= #{interval} )"
       i += 1
       query += "||" unless i == points.length
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
# takes only each n-th point
def create_coord_array(result, n)
   # extract waypoint information
    coords = Array.new
 
    doc = REXML::Document.new(result)
 
    i=0
    j=0
    doc.elements.each('waypoints/waypoint') do |ele|
      if i % n == 0
        coords[j] = Hash.new
        
        #temporary change because of mixed up values in DB
        coords[j][:lat] = ele.attributes["longitude"]
        coords[j][:lng] = ele.attributes["latitude"]
        
        #coords[j][:lat] = ele.attributes["latitude"]
        #coords[j][:long] = ele.attributes["longitude"]
        j +=1
      end
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

#TODO: extend to enable tracks with many coordinates
#IDEA: group waypoints in groups of 10, query sparql for each of them
#save label(title) of POI in a list, for each new solution check if already in list
def get_POIs(coords)
  begin
    sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
    
    #split coordinates
    interval = 0.01
    result = Array.new
    poi_IDs = Array.new
    j=0
    
    #size of chunks
    n=10
    for i in 0..coords.length/n
        queryString = querybuilder2(coords[i*n..(i+1)*n-1], interval)
        #puts queryString
        
        query = sparql.query(queryString)
        
        query.each_solution do |solution|
          if !poi_IDs.include?(solution[:label])
            page = solution[:subject].to_s.split('/').last
            link = "http://en.wikipedia.org/wiki/#{page}"
            result[j] = ""
            result[j] += "<poi>
            <title>#{solution[:label]}</title>
            <link>#{link}</link>
            <location latitutde=\"#{solution[:lat]}\" longitude=\"#{solution[:lng]}\" />
            </poi>"
            j += 1
            poi_IDs.push(solution[:label])         
          end
        end
    end
    
    rescue Exception => e
    # print exception, return nil instead
      puts e
      result = nil
    end
    return result
end