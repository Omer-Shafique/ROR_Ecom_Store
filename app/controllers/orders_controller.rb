class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :checkout]

  # Display a specific order
  def show
  end

  # Create a new order for a specific product
  def new
    @order = Order.find(params[:order_id])
  end

  # Create an order for a specific product
  def create
    @product = Product.find(params[:product_id])
    @order = Order.new(user: current_user, product: @product, status: 'pending')

    if @order.save
      redirect_to new_order_path(order_id: @order.id), notice: 'Proceed to checkout.'
    else
      redirect_to @product, alert: 'Error creating your order.'
    end
  end

  # List all orders for the current user
  def index
    @orders = current_user.orders
  end

  # Handle Stripe checkout and update order status
  def checkout
    if process_payment(@order)
      @order.update(status: "completed")
      redirect_to order_path(@order), notice: "Checkout complete!"
    else
      redirect_to order_path(@order), alert: "Payment failed. Please try again."
    end
  end

  private

  # Set the order and ensure the current user owns it
  def set_order
    @order = Order.find_by(id: params[:id])
    unless @order && @order.user == current_user
      redirect_to orders_path, alert: 'Order not found or unauthorized access.'
    end
  end

  # Example of Stripe payment processing
  def process_payment(order)
    begin
      Stripe::Charge.create(
        amount: (order.product.price * 100).to_i, # Convert to cents
        currency: 'usd',
        source: params[:stripeToken], # Ensure this token is passed
        description: "Charge for #{order.product.title}"
      )
      true
    rescue Stripe::CardError => e
      flash[:error] = e.message
      false
    end
  end
  
end
