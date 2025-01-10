class Admin::OrdersController < ApplicationController
  before_action :authorize_admin!

  def index
    @orders = Order.all  # Fetch all orders from the database
  end
end
