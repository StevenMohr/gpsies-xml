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
    @pois = PointOfInterest.all(uid: uid, page: page, offset: offset)
    
    #get coordinates for map
    @json = []
    @json << Track.map(uid)
    @json = @json.to_json
    
    
    if !@pois.empty?
      @total_count = @pois.first.total_count.to_f
    else
      @total_count = 0
    end
    
    @page = page
    @count = count
      
	unless @track
		render(
			file: "#{Rails.root}/public/404.html",
			layout: false,
			status: 404
		)
	end
  end
end
