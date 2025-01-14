class StripeChargeService
  def initialize(product, stripe_token)
    @product = product
    @stripe_token = stripe_token
  end

  def process_payment
    charge = Stripe::Charge.create(
      amount: (@product.price * 100).to_i,
      currency: 'usd',
      source: @stripe_token,
      description: "Charge for product #{@product.product_title}"
    )

    if charge.status == 'succeeded'
      @product.reduce_stripe_quantity
    end

    charge
  rescue Stripe::CardError => e
    raise e.message
  end
end
