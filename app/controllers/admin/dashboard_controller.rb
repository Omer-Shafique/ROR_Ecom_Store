class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @filter = params[:filter] || 'new_first'
  
    # Apply filtering based on the selected filter
    @orders = case @filter
              when 'new_first'
                Order.order(created_at: :desc)
              when 'old_first'
                Order.order(created_at: :asc)
              when 'fulfilled'
                Order.where(status: 'Fulfilled')
              when 'delivered'
                Order.where(status: 'Delivered')
              when 'by_id'
                Order.order(:id)
              else
                Order.all
              end

    # Paginate the filtered orders
    @orders = @orders.paginate(page: params[:page], per_page: 10)
  end

  def user_management
    @users = User.all
  end

  private

  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
