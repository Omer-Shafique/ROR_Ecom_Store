class CheckoutService
  attr_reader :error_message

  def initialize(product, stripe_token)
    @product = product
    @stripe_token = stripe_token
    @error_message = nil
  end

  def process_payment
    charge = create_charge
    if charge.status == 'succeeded'
      update_inventory(-1)
      true
    else
      @error_message = "Payment failed. Please try again."
      false
    end
  rescue Stripe::CardError => e
    @error_message = e.message
    false
  end

  private

  def create_charge
    Stripe::Charge.create(
      amount: (@product.price * 100).to_i,
      currency: 'usd',
      source: @stripe_token,
      description: @product.title
    )
  end

  def update_inventory(quantity_change)
    @product.update!(stock_quantity_string: @product.stock_quantity_string.to_i + quantity_change)
    @product.sync_stripe_inventory
  end
end
