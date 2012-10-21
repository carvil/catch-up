class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def current_user
    current = Session.find('current')
    @current_user ||= User.find(current.screen_name) if current
  end
  helper_method :current_user

end
