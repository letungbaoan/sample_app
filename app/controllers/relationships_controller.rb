class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_user_follow, only: :create
  before_action :load_relationship, only: :destroy

  # POST /relationships
  def create
    current_user.follow(@user)
    respond_to do |format|
      format.html {redirect_to @user}
      format.turbo_stream
    end
  end

  # DELETE /relationships/:id
  def destroy
    @user = @relationship.followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html {redirect_to @user}
      format.turbo_stream
    end
  end

  private
  def load_user_follow
    @user = User.find_by id: params[:followed_id]
    return if @user

    flash[:danger] = t("flash.not_found_user")
    redirect_to current_user
  end

  def load_relationship
    @relationship = Relationship.find_by id: params[:id]
    return if @relationship

    flash[:danger] = t(".not_found_relationship")
    redirect_to root_url
  end
end
