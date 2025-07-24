class PasswordResetsController < ApplicationController
  before_action :load_user_for_create, only: [:create]
  before_action :load_user_for_edit_update, :check_user_activation_status,
                :check_reset_token_authentication, :check_expiration,
                only: %i(edit update)

  # GET /password_resets/new
  def new; end

  # GET /password_resets/:id/edit
  def edit; end

  # POST /password_resets
  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t(".reset_password_email_sent", email: @user.email)
    redirect_to root_path
  end

  # PATCH /password_resets/:id
  def update
    if user_params[:password].empty?
      @user.errors.add :password
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params.merge(reset_digest: nil))
      log_in @user
      remember_session @user
      flash[:success] = t(".password_reset_success")
      redirect_to @user
    end
  end

  private
  def load_user_for_edit_update
    @user = User.find_by email: params[:email] || params.dig(:password_reset,
                                                             :email)
    return if @user

    flash[:danger] = t("flash.not_found_user")
    redirect_to root_url
  end

  def load_user_for_create
    email_param = params.dig(:password_reset, :email)&.downcase
    @user = User.find_by email: email_param

    return if @user

    flash.now[:danger] = t(".email_not_found", email: email_param)
    render :new, status: :unprocessable_entity
    nil
  end

  def check_user_activation_status
    return if @user.activated?

    flash[:danger] = t("flash.account_not_activated_error")
    redirect_to root_url
  end

  def check_reset_token_authentication
    return if @user.authenticated?(:reset, params[:id])

    flash[:danger] = t(".invalid_password_reset_token_error")
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit User::PASSWORD_RESET_PERMIT
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".password_reset_expired")
    redirect_to new_password_reset_url
  end
end
