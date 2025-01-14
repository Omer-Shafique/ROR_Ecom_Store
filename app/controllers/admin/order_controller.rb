class Admin::OrdersController < ApplicationController
  before_action :authorize_admin!

  def index
    @orders = Order.all 
  end

  # def show
  #   @order = Order.find(params[:id])
  # end
end
