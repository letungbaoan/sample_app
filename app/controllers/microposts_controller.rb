class MicropostsController < ApplicationController
  def index
    @microposts = Micropost.all
  end
end
