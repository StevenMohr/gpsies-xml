require 'date'
require 'pointOfInterest'

class TrackController < ApplicationController
  def index
	  @tracks = Track.select(count: 15)
  end

  def search
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
