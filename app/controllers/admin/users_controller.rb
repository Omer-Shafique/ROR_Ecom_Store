class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @users = User.all
  end

  def make_admin
  @user = User.find(params[:id])
  if @user.update(role: 'admin')
    respond_to do |format|
      format.html { redirect_to admin_dashboard_path, notice: "User promoted to admin." }
      format.js 
    end
  else
    flash.now[:alert] = "Failed to promote user."
    respond_to do |format|
      format.html { redirect_to admin_dashboard_path }
      format.js { render :make_admin_failure }
    end
  end
end

def destroy
  @user = User.find(params[:id])
  if @user.admin?
    flash.now[:alert] = "You cannot delete an admin user."
    respond_to do |format|
      format.html { redirect_to admin_dashboard_path }
      format.js { render :destroy_failure }
    end
  else
    if @user.destroy
      respond_to do |format|
        format.html { redirect_to admin_dashboard_path, notice: "User deleted." }
        format.js   # This will trigger the destroy.js.erb response
      end
    else
      flash.now[:alert] = "Failed to delete user."
      respond_to do |format|
        format.html { redirect_to admin_dashboard_path }
        format.js { render :destroy_failure }
      end
    end
  end
end


  private
  
  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end















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











