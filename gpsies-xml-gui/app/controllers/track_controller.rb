require 'date'
require 'pointOfInterest'

class TrackController < ApplicationController
  def index
	  count = (params[:c] || 20).to_i
	  page = (params[:p] || 1).to_i
	  offset = (page - 1) * count
	  query = params[:q]
	  
	  keywords = []
	  if query
		  keywords += query.split(' ')
	  end

	  @tracks = Track.select(count: count, offset: offset, keywords: keywords)
      
      if !@tracks.empty?
        @total_count = @tracks.first.total_count.to_f
      else
        @total_count = 0
      end
      
	  @page = page
      @count = count
      @query = query
  end

  def show
    uid = (params[:id])
    count = (params[:c] || 5).to_i
    page = (params[:p] || 1).to_i
    offset = (page - 1) * count
    
	@track = Track.find(params[:id])
    
   unless @track
    render(
      file: "#{Rails.root}/public/404.html",
      layout: false,
      status: 404
      )
    end
    
    @pois = PointOfInterest.all(uid: uid, page: page, offset: offset, twitter: true, sparql: true)
    
    #get coordinates for map
    @route_json = Track.map(uid).to_json
    @points_json = []    
    
    @points_json << { title: "Startpoint", description: "Startpoint", lng: @track.start_point[:lng], lat: @track.start_point[:lat] }
    @points_json << { title: "Endpoint", description: "Endpoint", lng: @track.end_point[:lng], lat: @track.end_point[:lat] }
    
    #TODO: decide if all POIs or just paginated ones
    #all_pois = PointOfInterest.all(uid: uid, all: true, twitter: false) 
        
    @pois.each do |poi| 
       @points_json << { description: poi.title, lng: poi.location[:lng], lat: poi.location[:lat] }
    end
    
    @points_json = @points_json.to_json    
    
    
    if !@pois.empty?
      @total_count = @pois.first.total_count.to_f
    else
      @total_count = 0
    end
    
    @page = page
    @count = count
  end
end
