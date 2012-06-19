require 'date'

class TrackController < ApplicationController
  def index
	  @tracks = Track.all
  end

  def show
	  begin
		  @track = Track.find(params[:id])
	  rescue
		   render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404 
	  end
  end
end
