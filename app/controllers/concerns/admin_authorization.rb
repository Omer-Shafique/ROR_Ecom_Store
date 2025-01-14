module AdminAuthorization
  extend ActiveSupport::Concern

  def authorize_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
end
