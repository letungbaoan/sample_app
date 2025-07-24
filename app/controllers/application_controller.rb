class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper
  include Pagy::Backend

  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  private
  def logged_out_user
    return unless logged_in?

    flash[:info] = t("flash.already_logged_in")
    redirect_to root_url
  end
end
