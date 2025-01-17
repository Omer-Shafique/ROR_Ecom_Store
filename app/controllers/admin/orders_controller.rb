class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:fulfill, :out_for_delivery, :delivered ] 

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

  private

  def set_order
    @order = Order.find_by(id: params[:id])
  end
end
