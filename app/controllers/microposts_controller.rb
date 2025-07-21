class MicropostsController < ApplicationController
  # GET /microposts/index
  def index
    @microposts = Micropost.all
  end
end
