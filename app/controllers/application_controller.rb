class ApplicationController < ActionController::Base
  # Disable CSRF protection for API requests or specific actions
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
end
