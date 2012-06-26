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
	  @page = page
  end

  def show
	@track = Track.find(params[:id])
	unless @track
		render(
			file: "#{Rails.root}/public/404.html",
			layout: false,
			status: 404
		)
	end
  end
end
