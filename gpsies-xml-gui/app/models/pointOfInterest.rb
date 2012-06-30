require 'basex/BaseXClient'
require 'xmlsimple'
require "../config/basex.rb"
require 'sparql/SparqlClient.rb'
require 'twitter'

class PointOfInterest
  attr_reader :title, :link, :tweet, :total_count
  
  def initialize(params = {})
	@title = params[:title]
	@link = params[:link]
	@tweet = params[:tweet]
    @total_count = params[:total_count]
  end

  def self.all(params = {})
      uid = params[:uid]
      offset = params[:offset] || 0
      count = params[:count] || 5
              
              
    begin
	dbconfig =  Gpsies::CONFIG[:database]

    q = "#{dbconfig[:nsdec]} let $pois := (for $track in track where $track/uid = \"#{uid}\" return $track/pois/poi)
            for $poi at $count in subsequence($pois, #{offset + 1}, #{count})
            return
              <poi>
                  {$poi/title}
                  {$poi/link}
                  {if ($count=1) then <count>{count($pois)}</count> else ()}
              </poi>"
              
   
    pois = query(q)
      
    if pois.empty?
      sparclclient = Sparql::SparqlClient.new(dbconfig[:host], dbconfig[:port], dbconfig[:user], dbconfig[:pass])
      sparclclient.execute("open #{dbconfig[:database]}")
      
      new_pois = sparclclient.fetch_POIs_from_SPARQL(uid)
      sparclclient.close
    end
	  
    pois = query(q)

    rescue Exception => e
      puts e
    end
	
    pois
  end
  
  
  protected
    def self.query(str)
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
            return [] unless query
            begin
                while query.more
                    t = query.next
          
                    xml = XmlSimple.xml_in(t)
                    
                    twitterresult = Twitter.search("#{xml['title'].first}", :lang => "de", :rpp => 1).first
                    unless twitterresult.nil?
                      tweet = twitterresult.text
                    else
                      tweet = nil
                    end
                    
                    #add total count for the first item
                    if result.empty?
                      result << PointOfInterest.new(
                          title: xml['title'].first,
                          link: xml['link'].first,
                          tweet: tweet,
                          total_count: xml['count'].first
                      )
                    else
                       result << PointOfInterest.new(
                          title: xml['title'].first,
                          link: xml['link'].first,
                          tweet: tweet,
                      )
                    end
                                       
                end
            ensure
                query.close
            end
        rescue Exception => e
          puts e
        ensure
            session.close
        end
        result
    end	
end
