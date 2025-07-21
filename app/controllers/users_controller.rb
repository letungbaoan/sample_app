class UsersController < ApplicationController
  before_action :load_user, except: %i(new create)
  before_action :logged_in_user, only: %i(edit update)
  before_action :correct_user, only: %i(edit update)
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
      log_in @user
      flash[:success] = t "flash.welcome_message"
      redirect_to @user, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t("flash.profile_updated")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "flash.not_found_user"
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit User::USER_PERMIT
  end

  def logged_in_user
    return if logged_in?

    flash[:danger] = t("flash.please_log_in")
    redirect_to login_url
  end

  def correct_user
    return if @user == current_user

    flash[:danger] = t("flash.cannot_edit_another_user")
    redirect_to root_url
  end
end
