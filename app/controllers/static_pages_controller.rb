class StaticPagesController < ApplicationController
  # GET / (root_path) or GET /home
  def home
    return unless logged_in?

    @micropost = current_user.microposts.build
    @pagy, @feed_items = pagy current_user.microposts.newest,
                              limit: Settings.development.pagy.page_10
  end

  # GET /help
  def help; end

  # GET /contact
  def contact; end
end
