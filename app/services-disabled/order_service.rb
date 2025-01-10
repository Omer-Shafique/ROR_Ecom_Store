# app/services/orders_service.rb
class OrdersService
  attr_reader :user, :params

  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def find_order(order_id)
    Order.find_by(id: order_id).tap do |order|
      return nil unless order && order.user == user
    end
  end

  def create_order
    product = Product.find_by(id: params[:product_id])
    return { redirect_path: root_path, alert: 'Product not found.' } unless product

    order = Order.new(user: user, product: product, status: "pending")
    if order.save
      { redirect_path: new_order_path(order_id: order.id), notice: 'Proceed to checkout.' }
    else
      { redirect_path: product, alert: 'Error creating your order.' }
    end
  end

  def fetch_all_orders
    Order.all
  end

  def process_checkout(order)
    if process_payment(order)
      order.update(status: "completed")
      { redirect_path: order_path(order), notice: "Checkout complete!" }
    else
      { redirect_path: order_path(order), alert: "Payment failed. Please try again." }
    end
  end

  private

  def process_payment(order)
    Stripe::Charge.create(
      amount: (order.product.price * 100).to_i,
      currency: 'usd',
      source: params[:stripeToken],
      description: "Charge for #{order.product.title}"
    )
    true
  rescue Stripe::CardError => e
    false
  end
end
