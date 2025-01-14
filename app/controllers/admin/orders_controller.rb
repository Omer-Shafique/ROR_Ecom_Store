class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:fulfill, :out_for_delivery]
  before_action :find_user, only: [:make_admin]

  def fulfill
    if @order.update(status: 'Fulfilled')
    end
  end

  def out_for_delivery
    if @order.status == 'Fulfilled' && @order.update(status: 'Out for Delivery')
    end
  end

  def delivered
    if @order.status == 'Out for Delivery' && @order.update(status: 'Delivered')
    end
  end

  def make_admin
    if @user.update(role: 'admin') 
      flash[:notice] = "User has been made an admin."
    else
      flash[:alert] = "Failed to assign admin role."
    end
    redirect_to admin_users_path
  end

  private

  def find_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "User not found."
    redirect_to admin_users_path
  end
  
  def set_order
    @order = Order.find(params[:id])
  end
end
