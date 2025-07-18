class UsersController < ApplicationController
  before_action :load_user, except: %i(new create)

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t "flash.welcome_message"
      redirect_to @user, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t(".not_found_user")
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit User::USER_PERMIT
  end
end
