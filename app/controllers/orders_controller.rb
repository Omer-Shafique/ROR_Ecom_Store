class OrdersController < ApplicationController
  before_action :set_order, only: [:show]

  def show
    # @order should be already set by the set_order method
  end

  def fulfill
    @order = Order.find(params[:id])

    if @order.update(status: 'fulfilled')
      respond_to do |format|
        format.html { redirect_to admin_dashboard_path, notice: "Order ##{@order.id} has been fulfilled." }
        format.js # Render a corresponding JavaScript response
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_dashboard_path, alert: "Failed to fulfill Order ##{@order.id}." }
        format.js { render js: "alert('Failed to fulfill the order.');" }
      end
    end
  end

  def checkout
    @product = Product.find(params[:id])

    # Handle Stripe token and process the order
    stripe_token = params[:stripeToken]
    customer = Stripe::Customer.create(
      email: params[:email],
      source: stripe_token
    )

    # Create the order
    order = Order.new(
      product: @product,
      customer_name: params[:name],
      customer_email: params[:email],
      customer_address: params[:address],
      customer_phone: params[:phone],
      stripe_customer_id: customer.id
    )

    if order.save
      # Redirect to the order details page if the order is successfully saved
      redirect_to order_path(order), notice: "Order placed successfully!"
    else
      # Redirect back with an error if order creation fails
      redirect_to checkout_product_path(@product), alert: "Failed to place order."
    end
  rescue StandardError => e
    # Handle errors (e.g., Stripe errors)
    redirect_to checkout_product_path(@product), alert: "Payment failed: #{e.message}"
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id])
    if @order.nil?
      flash[:error] = "Order not found"
      redirect_to root_path # Or any other path you want
    end
  end
end
