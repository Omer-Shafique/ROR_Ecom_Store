class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    # @orders = Order.includes(:user).all
    @orders = Order.paginate(page: params[:page], per_page: 5)
    @users = User.all
  end

  private

  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
