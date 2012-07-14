def get_POIs(coords)
  begin
    sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
    
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