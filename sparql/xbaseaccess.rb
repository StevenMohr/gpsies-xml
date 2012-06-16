require 'BaseXClient.rb'

def get_waypoints(id) 
  # create session
  session = BaseXClient::Session.new("localhost", 1984, "admin", "admin")

  begin
    # create query instance
    input = "for $x in doc('example2')/database/tracks/track
    where $x/uid = \"#{id}\"
    return $x/waypoints"
    query = session.query(input)

    result = query.next
    
    query.close()
    
    return result
      
  rescue Exception => e
    # print exception
    puts e
  end

  # close session
  session.close
end

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
  end

  rescue Exception => e
  # print exception
    puts e
  end

  # close session
  session.close
end