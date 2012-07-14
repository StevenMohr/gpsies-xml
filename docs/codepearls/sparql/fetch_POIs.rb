def fetch_POIs_from_SPARQL(id)
      begin
        points = get_waypoints(id)
        #take only each 20th point:
        coords = create_coord_array(points,20) 
        result = get_POIs(coords)
              
        if !result.nil?
          res = insert_pois(id, result)
          if !res.nil?
            pois = "<pois>#{result}</pois>"
          else
            pois=nil
          end
        end
        rescue Exception => e
          puts e
        end
end