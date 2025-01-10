class StripeService
  attr_reader :params, :request

  def initialize(request_or_params)
    if request_or_params.is_a?(ActionDispatch::Request)
      @request = request_or_params
    else
      @params = request_or_params
    end
  end

  # Handles webhook events from Stripe
  def handle_webhook
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error("Stripe webhook error: #{e.message}")
      head :bad_request
      return
    end

    process_event(event)
    head :ok
  end

  # Process different event types
  def process_event(event)
    case event["type"]
    when "charge.succeeded"
      handle_charge_succeeded(event)
    end
  end

  # Handle successful charge event
  def handle_charge_succeeded(event)
    charge = event["data"]["object"]
    product = Product.find_by(title: charge["description"])
    product.update!(stock_quantity_string: product.stock_quantity_string.to_i - 1) if product
  end

  # Checkout logic for a product
  def checkout_product
    product = Product.find(params[:id])
    user_name = params[:name]
    user_email = params[:email]
    stripe_token = params[:stripeToken]

    image_url = product.images.attached? ? Rails.application.routes.url_helpers.rails_blob_path(product.images.first, only_path: true) : nil
    charge = create_stripe_charge(product, stripe_token, user_name, user_email, image_url)

    if charge.paid
      { flash_key: :success, message: "Payment successful! Thank you, #{user_name}.", redirect_path: success_path }
    else
      { flash_key: :error, message: "Payment failed. Please try again.", redirect_path: checkout_product_path(product) }
    end
  rescue Stripe::CardError => e
    { flash_key: :error, message: e.message, redirect_path: checkout_product_path(product) }
  end

  # Create a Stripe charge
  def create_stripe_charge(product, stripe_token, user_name, user_email, image_url)
    Stripe::Charge.create({
      amount: (product.price * 100).to_i,
      currency: "usd",
      description: "#{product.product_title} - #{image_url}",
      source: stripe_token,
      receipt_email: user_email,
      metadata: { "Name" => user_name, "Email" => user_email, "Product Image" => image_url }
    })
  end
end
