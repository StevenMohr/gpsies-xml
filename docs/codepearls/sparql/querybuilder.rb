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