class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate

  private

  def authenticate
    @current_user = User.find(session[:user_id]) if session[:user_id].present?
  end

  def check_if_logged_in
    redirect_to(new_user_path) if @current_user.nil?
  end
end
