class ApplicationController < ActionController::Base
  before_action :set_latest_order
  before_action :configure_permitted_parameters, if: :devise_controller?
  include DeviseParameters
  include AdminAuthorization
  
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :date_of_birth])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :date_of_birth])
  end
  private
  
  def set_latest_order
    @latest_order = Order.last
  end
end
