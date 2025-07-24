class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :logged_out_user, only: %i(new create)
  before_action :admin_user, only: :destroy

  # GET /users/:id
  def show; end

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t(".check_email_for_activation")
      redirect_to root_url, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    if @user.destroy
      flash[:success] = t(".user_deleted")
    else
      flash[:danger] = t(".delete_failed")
    end
    redirect_to users_path
  end

  # GET /users/:id/edit
  def edit; end

  # PATCH /users/:id
  def update
    if @user.update(user_params)
      flash[:success] = t(".profile_updated")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /users
  def index
    @pagy, @users = pagy User.recent
  end

  private
  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t("flash.not_found_user")
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit User::USER_PERMIT
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t("flash.please_log_in")
    redirect_to login_url
  end

  def logged_out_user
    return unless logged_in?

    flash[:info] = t("flash.already_logged_in")
    redirect_to root_url
  end

  def correct_user
    return if current_user?(@user)

    flash[:danger] = t("flash.cannot_edit_another_user")
    redirect_to root_url
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = t("flash.not_authorized")
    redirect_to root_path
  end
end
