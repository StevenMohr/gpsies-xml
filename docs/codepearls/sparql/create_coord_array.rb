def create_coord_array(result, n)
    coords = Array.new
 
    doc = REXML::Document.new(result)
 
    i=0
    j=0
    doc.elements.each('waypoints/waypoint') do |ele|
      if i % n == 0
        coords[j] = Hash.new

        coords[j][:lat] = ele.attributes["latitude"]
        coords[j][:lng] = ele.attributes["longitude"]
        j +=1
      end
      i += 1
    end
    return coords
end