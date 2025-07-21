class UsersController < ApplicationController
  before_action :load_user, only: %i(edit update)

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
    # Handle a successful update.
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
end
