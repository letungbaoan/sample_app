class SessionsController < ApplicationController
  before_action :logged_out_user, only: %i(new create)
  REMEMBER_ME_CONSTANT = "1".freeze

  # GET /login
  def new; end

  # POST /login
  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user.try(:authenticate, params.dig(:session, :password))
      handle_successful_login user
    else
      handle_failed_login
    end
  end

  # DELETE /logout
  def destroy
    log_out
    reset_session
    redirect_to root_url, status: :see_other
  end

  private
  def handle_successful_login user
    forwarding_url = session[:forwarding_url]
    reset_session
    log_in user
    if params.dig(:session,
                  :remember_me) == REMEMBER_ME_CONSTANT
      remember_cookies(user)
    else
      remember_session(user)
    end
    redirect_to forwarding_url || user
  end

  def handle_failed_login
    flash.now[:danger] = t(".invalid_email_password_combination")
    render :new, status: :unprocessable_entity
  end
end
