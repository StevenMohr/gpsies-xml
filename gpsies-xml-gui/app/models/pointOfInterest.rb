require 'basex/BaseXClient'
require 'xmlsimple'
require "../config/basex.rb"
require 'sparql/SparqlClient.rb'
require 'twitter'

class PointOfInterest
  attr_reader :title, :link, :tweet, :total_count, :location
  
  def initialize(params = {})
	@title = params[:title]
	@link = params[:link]
	@tweet = params[:tweet]
    @total_count = params[:total_count]
    @location = params[:location]
  end

  def self.all(params = {})
      uid = params[:uid]
      offset = params[:offset] || 0
      count = params[:count] || 5
      all = params[:all] || false               #if true, will ignore pagination and return all POIs
      twitter = params[:twitter] || true        #if true, will include tweets in the result
      sparql = params[:sparql] || false         #if true, will try to fetch POIs from SPARQL if there a no POIs in the database
              
    begin
      dbconfig =  Gpsies::CONFIG[:database]
      
      if all
        subsequence = "$pois"
      else
        subsequence = "subsequence($pois, #{offset + 1}, #{count})"
      end        

      q = "#{dbconfig[:nsdec]} for $track in track where $track/uid = \"#{uid}\"
              return count($track/pois/poi)"
    
      poi_count = query(query: q, twitter: false, count_only: true).to_i
      puts poi_count
        
      if poi_count==0 && sparql
        sparclclient = Sparql::SparqlClient.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
        sparclclient.execute("open #{dbconfig[:database]}")
        
        new_pois = sparclclient.fetch_POIs_from_SPARQL(uid)
        sparclclient.close
      end
      
      q = "#{dbconfig[:nsdec]}
           let $pois := (for $track in track where $track/uid = \"#{uid}\" return $track/pois/poi)
              for $poi at $count in #{subsequence}
              return
                <poi>
                    {$poi/title}
                    {$poi/link}
                    <location><lat>{data($poi/location/@latitude)}</lat><lng>{data($poi/location/@longitude)}</lng></location>
                    {if ($count=1) then <count>{count($pois)}</count> else ()}
                </poi>"
                
        pois = query(query: q, twitter: twitter)
      
      
      rescue Exception => e
        puts e
      end
      
      pois
    end 
  
  protected
    def self.query(params = {})
      str = params[:query] || nil
      twitter = params[:twitter] || false
      count_only = params[:count_only] || false 
        
      dbconfig =  Gpsies::CONFIG[:database]
      session = BaseXClient::Session.new(
                  dbconfig[:host],
                  dbconfig[:port],
                  dbconfig[:user],
                  dbconfig[:pass]
                )
      
      result = []
      begin
        session.execute("open #{dbconfig[:database]}")
        query = session.query(str)
        
        if count_only
            return query.next
        end
         
        return [] unless query
        
        while query.more
          t = query.next
          xml = XmlSimple.xml_in(t)
                   
          if twitter
            twitterresult = Twitter.search("#{xml['title'].first}", :lang => "de", :rpp => 1).first
            unless twitterresult.nil?
              tweet = twitterresult.text
            else
              tweet = nil
            end
          else
            tweet = nil
          end
                    
                   
          location = { lng: xml['location'].first['lng'].first, lat: xml['location'].first['lat'].first }
          if result.empty?
            result << PointOfInterest.new(
                        title: xml['title'].first,
                        link: xml['link'].first,
                        tweet: tweet,
                        location: location,
                        total_count: xml['count'].first
                      )
          else
            result << PointOfInterest.new(
                        title: xml['title'].first,
                        link: xml['link'].first,
                        tweet: tweet,
                        location: location
                      )
          end
        end
                                       
        rescue Exception => e
          puts e
        ensure
          query.close unless query.nil?
          session.close unless session.nil?
        end
        result
    end	
end
