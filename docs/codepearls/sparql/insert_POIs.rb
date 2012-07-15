def insert_pois(id, pois)
  begin
    dbconfig =  Gpsies::CONFIG[:database]
      
    pois.each do |point|
      if point == pois.first            
        queryString = "xquery #{dbconfig[:nsdec]}
          for $x in track
          where $x/uid = \"#{id}\"
          return (            
            insert nodes <pois>#{point}</pois>
            as last into $x
          )"
      else
        queryString = "xquery #{dbconfig[:nsdec]}
          for $x in track
            where $x/uid = \"#{id}\"
            return (            
              insert nodes #{point}
              as last into $x/pois
            )"
      end
      
      if !self.execute(queryString)
        raise "Error while executing query \"#{queryString}\""
      end
   end
   result = "Insert successful"

  rescue Exception => e
    raise e
  end
    result
  end
end