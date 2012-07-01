require 'sparql/client'

require 'basex/BaseXClient.rb'
require 'sparql/queryhelper.rb'
require 'sparql/CustomExceptions.rb'
require '../config/basex.rb'

module Sparql
  class SparqlClient
    
    #raises DatabaseConnectionError
    def initialize(host,port,username,password)
      begin
        @session = BaseXClient::Session.new(host, port, username, password)
      rescue Exception => e
        raise DatabaseConnectionError
      end
    end
    
    #raises DatabaseOpeningError
    def open(db)
      begin
        @session.execute("open #{db}")
        result = "DB #{db} successfully opened"
      rescue Exception => e
        raise DatabaseOpeningError
      end      
    end
    
    
    #for a given ID gets waypoints from database,
    #fetches POIs from sparql
    #inserts them into our XML-database
    #returns POIs as XML string
    #raises QueryError
    def fetch_POIs_from_SPARQL(id)
      begin
        points = get_waypoints(id)
        #take only each 10th point:
        coords = create_coord_array(points,20) 
        result = get_POIs(coords)
        puts result
              
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

    #raises DatabaseConnectionError
    def close
      begin
        @session.close
      rescue Exception => e
        raise DatabaseConnectionError
      end 
    end

    def query(queryString)
      begin    
        query = @session.query(queryString)
        result = query.next      
        query.close()
      rescue Exception => e
        raise QueryError
      end
        result
    end

    def execute(queryString)
      begin
        query = @session.execute(queryString)
        result = "Execute successful"

      rescue Exception => e
          raise QueryError
      end    
        result
      end
    
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
    
    private
    
    def insert_pois(id, pois)
      begin
        dbconfig =  Gpsies::CONFIG[:database]
        
        puts "Anzahl POIs: #{pois.length}"
      
        pois.each do |point|
          if point == pois.first            
            queryString = "xquery #{dbconfig[:nsdec]}
            for $x in track
            where $x/uid = \"#{id}\"
            return (            
              insert nodes <pois>#{point}</pois>
              as last into $x
            )"
            puts queryString
          else
            queryString = "xquery #{dbconfig[:nsdec]}
            for $x in track
            where $x/uid = \"#{id}\"
            return (            
              insert nodes #{point}
              as last into $x/pois
            )"
            puts queryString
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
end