require 'BaseXClient.rb'

#returns waypoints as XML-String if successful, nil otherwise
def get_waypoints(id) 
  # create session
  session = BaseXClient::Session.new("localhost", 1984, "admin", "admin")

  begin
    input = "for $x in doc('example2')/database/tracks/track
    where $x/uid = \"#{id}\"
    return $x/waypoints"
    query = session.query(input)

    result = query.next
    
    query.close()
      
  rescue Exception => e
    # print exception
    puts e
    result = nil
  end

  # close session
  session.close
  return result
end

#returns "Insert successful" if insert was succcessful, nil otherwise
def insert_pois(id, pois)
  begin
  session = BaseXClient::Session.new("localhost", 1984, "admin", "admin")
  
  session.execute("open example2")
  #print "\n" + session.info()
  
  pois.each do |point|
    queryString = "xquery for $x in doc('example2')/database/tracks/track
    where $x/uid = \"#{id}\"
    return (            
      insert node #{point}
      as first into $x/pois
    )"
    
    query = session.execute(queryString)
    result = "Insert successful"
  end

  rescue Exception => e
  # print exception, return nil instead
    puts e
    result = nil
  end

  # close session
  session.close
  return result
end