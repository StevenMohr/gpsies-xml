require 'rubygems'
require 'sparql/client'

require 'xbaseaccess.rb'
require 'queryhelper.rb'


def get_pois(id)
  sparql = SPARQL::Client.new("http://dbpedia.org/sparql")

  result = get_waypoints(id)
  coords = create_coord_array(result)

  interval = 0.005
  #queryString = querybuilder(coords, interval)
  queryString = querybuilder2(coords, interval)

  if queryString
    query = sparql.query(queryString)
    
    result = Array.new
    i = 0
    
    query.each_solution do |solution|
      page = solution[:subject].to_s.split('/').last
      link = "http://en.wikipedia.org/wiki/#{page}"
      result[i] = ""
      result[i] += "<poi>
      <title>#{solution[:label]}</title>
      <link>#{link}</link>
      <location latitutde=\"#{solution[:lat]}\" longitude=\"#{solution[:long]}\" />
      </poi>"
      i += 1
    end

    return result
  else
    puts "No Waypoints found"
    return nil
  end
end

#nullrequest
#result = get_pois("1")
#puts result if !result.nil?

id = "blah"
result = get_pois(id)
puts result if !result.nil?

insert_pois(id, result)