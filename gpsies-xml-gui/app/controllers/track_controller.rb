require 'date'

class TrackController < ApplicationController
  def index
	  @tracks = Track.all
  end

  def show
	  @track = Track.find(params[:id])
  end
end
