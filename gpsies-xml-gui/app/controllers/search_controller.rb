require 'date'
class SearchController < ApplicationController
  def index
	  @date = DateTime.now.to_s
  end

  def query
  end
end
