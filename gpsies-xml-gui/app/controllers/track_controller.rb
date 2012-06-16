require 'date'

class TrackController < ApplicationController
  def index
	  # @date = DateTime.now.to_s
	  @tracks = Track.all
  end

  def show
	  @track = Track.find(params[:id])
  end
end
