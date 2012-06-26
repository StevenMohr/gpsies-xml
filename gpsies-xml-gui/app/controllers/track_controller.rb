require 'date'

class TrackController < ApplicationController
  def index
	  @tracks = Track.all
  end

  def search
    if params[:keyword]?
      @track = Track.find(:keyword => params[:keyword])
    else
      @track = Track.find()
  end

  def show
	  begin
		  @track = Track.find(:id => params[:id])
	  rescue
		   render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404 
	  end
  end
end
