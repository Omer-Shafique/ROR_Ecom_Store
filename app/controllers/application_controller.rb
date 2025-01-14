class ApplicationController < ActionController::Base
  include DeviseParameters
  include AdminAuthorization

  protect_from_forgery with: :null_session, if: -> { request.format.json? }
end















# class ApplicationController < ActionController::Base

#   # before_action :authenticate_user!
#   before_action :configure_permitted_parameters, if: :devise_controller?


#   protected

#   def configure_permitted_parameters
#     devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
#     devise_parameter_sanitizer.permit(:account_update, keys: [:role])
#   end

  
#   def authorize_admin!
#     unless current_user&.admin?
#       redirect_to root_path, alert: "You are not authorized to perform this action."
#     end
#   end

  
#   protect_from_forgery with: :null_session, if: -> { request.format.json? }
# end
  
