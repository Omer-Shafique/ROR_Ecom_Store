# class Admin::UsersController < ApplicationController
#   before_action :authenticate_user!
#   before_action :authorize_admin!

#   # Action to delete a user
#   def destroy
#     @user = User.find(params[:id])
#     service = UserService.new(@user)

#     result = service.delete_user
#     redirect_to admin_dashboard_path, notice: result[:message] if result[:success]
#     redirect_to admin_dashboard_path, alert: result[:message] unless result[:success]
#   end

#   # Action to promote user to admin
#   def make_admin
#     @user = User.find(params[:id])
#     service = UserService.new(@user)

#     result = service.promote_to_admin
#     redirect_to admin_dashboard_path, notice: result[:message] if result[:success]
#     redirect_to admin_dashboard_path, alert: result[:message] unless result[:success]
#   end

#   private

#   # Ensure only admins can access this controller
#   def authorize_admin!
#     unless current_user.admin?
#       redirect_to root_path, alert: "You are not authorized to access this page."
#     end
#   end
# end










class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  # Action to delete a user
  def destroy
    @user = User.find(params[:id])

    # Prevent deletion of admin users
    if @user.admin?
      redirect_to admin_dashboard_path, alert: "You cannot delete an admin user."
    else
      if @user.destroy
        redirect_to admin_dashboard_path, notice: "User has been deleted."
      else
        redirect_to admin_dashboard_path, alert: "Failed to delete user."
      end
    end
  end

  # Action to promote user to admin
  def make_admin
    user = User.find(params[:id])
    if user.update(admin: true)
      redirect_to admin_dashboard_path, notice: "#{user.name} is now an admin."
    else
      redirect_to admin_dashboard_path, alert: "Failed to make #{user.name} an admin."
    end
  end

  # Ensure only admins can access this controller
  private

  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
