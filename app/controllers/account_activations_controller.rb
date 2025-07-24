class AccountActivationsController < ApplicationController
  before_action :load_user_for_activation, only: [:edit]

  # GET /account_activations/:id/edit
  def edit
    if user_can_be_activated?(@user)
      activate_and_log_in_user(@user)
    else
      handle_invalid_activation_link
    end
  end

  private

  def load_user_for_activation
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t(".invalid_activation_link")
    redirect_to root_url
  end

  def user_can_be_activated? user
    !user.activated? &&
      user.authenticated?(:activation, params[:id])
  end

  def activate_and_log_in_user user
    user.activate
    log_in user
    remember_session user
    flash[:success] = t(".account_activated")
    redirect_to user
  end

  def handle_invalid_activation_link
    flash[:danger] = t(".invalid_activation_link")
    redirect_to root_url
  end
end
