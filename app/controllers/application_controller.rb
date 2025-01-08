class ApplicationController < ActionController::Base

  before_action :authenticate_user!


  def authorize_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
end
  
