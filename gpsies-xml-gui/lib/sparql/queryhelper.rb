require 'net/http'
require 'rexml/document'
#takes an array of hashes (latitude-longitude pairs :lat :long)
#and an interval for the points
#returns a SPARQL-Query
def querybuilder(points, interval)
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
        ?long - #{p[:lng]} <= #{interval} &&
        #{p[:lng]} - ?long <= #{interval} )"
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


#creates an array of hashes (latitude-longitude pairs :lat :lng)
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
        #coords[j][:lat] = ele.attributes["longitude"]
        #coords[j][:lng] = ele.attributes["latitude"]
        
        coords[j][:lat] = ele.attributes["latitude"]
        coords[j][:lng] = ele.attributes["longitude"]
        j +=1
      end
      i += 1
    end
    return coords
end


#for an array of lat-long coords
#fethces POIs from sparql
#returns POIs as XML-string
def get_POIs(coords)
  begin
    sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
    
    #split coordinates
    interval = 0.01
    result = Array.new
    poi_IDs = Array.new
    j=0
    
    n=10 #n = number of waypoints per SPARQL-query
    for i in 0..coords.length/n
        queryString = querybuilder(coords[i*n..(i+1)*n-1], interval)
        
        query = sparql.query(queryString)
        
        query.each_solution do |solution|
          if !poi_IDs.include?(solution[:label])
            page = solution[:subject].to_s.split('/').last
            link = "http://en.wikipedia.org/wiki/#{page}"
            result[j] = ""
            result[j] += "<poi>
            <title>#{solution[:label]}</title>
            <link>#{link}</link>
            <location latitude=\"#{solution[:lat]}\" longitude=\"#{solution[:long]}\" />
            </poi>"

            j += 1
            poi_IDs.push(solution[:label])         
          end
        end
    end
    
  rescue Exception => e
    puts e
    result = nil
  end
    result
end