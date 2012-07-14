def get_waypoints(id)
  begin
    dbconfig =  Gpsies::CONFIG[:database]
    input = "#{dbconfig[:nsdec]} for $x in track    
    where $x/uid = \"#{id}\"
    return $x/waypoints"

    result = self.query(input)
  rescue Exception => e
      raise e
  end
  result
end