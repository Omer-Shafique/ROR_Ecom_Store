class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :checkout]
  before_action :authorize_admin!, only: [:index]

  def show
  end

  def new
    @order = Order.find(params[:order_id])
  end

  def create
    @product = Product.find(params[:product_id])
    @order = Order.new(user: current_user, product: @product, status: "pending")

    if @order.save
      redirect_to new_order_path(order_id: @order.id), notice: 'Proceed to checkout.'
    else
      redirect_to @product, alert: 'Error creating your order.'
    end
  end

  def index
    @orders = Order.all
  end

  def checkout
    if process_payment(@order)
      @order.update(status: "completed")
      redirect_to order_path(@order), notice: "Checkout complete!"
    else
      redirect_to order_path(@order), alert: "Payment failed. Please try again."
    end
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id])
    unless @order && @order.user == current_user
      redirect_to orders_path, alert: 'Order not found or unauthorized access.'
    end
  end

  def authorize_admin!
    unless current_user.admin?
      redirect_to orders_path, alert: "You are not authorized to view all orders."
    end
  end

  def process_payment(order)
    begin
      Stripe::Charge.create(
        amount: (order.product.price * 100).to_i,
        currency: 'usd',
        source: params[:stripeToken],
        description: "Charge for #{order.product.title}"
      )
      true
    rescue Stripe::CardError => e
      flash[:error] = e.message
      false
    end
  end
end
