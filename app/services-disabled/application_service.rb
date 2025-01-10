class ApplicationService
  def initialize(user, paths)
    @user = user
    @paths = paths
  end

  # Redirect users after sign-in
  def redirect_after_sign_in
    @user.admin? ? @paths.admin_dashboard_path : @paths.root_path
  end

  # Authorize admin users
  def authorize_admin
    unless @user&.admin?
      raise NotAuthorizedError
    end
  rescue NotAuthorizedError
    redirect_to @paths.root_path, alert: "You are not authorized to perform this action."
  end
end
