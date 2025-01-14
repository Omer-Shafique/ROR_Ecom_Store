class StripePaymentService
  def initialize(product, stripe_token, order_params = nil)
    @product = product
    @stripe_token = stripe_token
    @order_params = order_params
  end

  # Process payment via Stripe and handle the charge
  def process_payment
    charge_service = StripeChargeService.new(@product, @stripe_token)
    charge = charge_service.process_payment
    charge
  end

    # If payment is successful, reduce product quantity
    @product.reduce_stripe_quantity if charge.status == 'succeeded'

    charge
  rescue Stripe::CardError => e
    raise e.message # Provide clear error message
  end

  # Create an order after payment or fetch an existing one
  def create_order_and_process_payment
    OrderParamsValidator.validate(@order_params)

    order_service = OrderService.new(@product, @order_params, @stripe_token)
    order = order_service.create_order

    order
  end
end
