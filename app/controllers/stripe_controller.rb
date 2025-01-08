class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
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

    case event["type"]
    when "charge.succeeded"
      charge = event["data"]["object"]
      product = Product.find_by(title: charge["description"])
      product.update!(stock_quantity_string: product.stock_quantity_string.to_i - 1) if product
    end

    head :ok
  end


  def checkout_product
    @product = Product.find(params[:id])
    # Retrieve the submitted name and email
    user_name = params[:name]
    user_email = params[:email]
    stripe_token = params[:stripeToken]


    image_url = @product.images.attached? ? Rails.application.routes.url_helpers.rails_blob_path(@product.images.first, only_path: true) : nil
    charge = Stripe::Charge.create({
    amount: (@product.price * 100).to_i,
    currency: "usd",
    description: "#{@product.product_title} - #{image_url}",
    source: stripe_token,
    receipt_email: user_email, # Pass email for receipt
    metadata: { "Name" => user_name, "Email" => user_email, "Product Image" => image_url }
  })
    if charge.paid
      flash[:success] = "Payment successful! Thank you, #{user_name}."
      redirect_to success_path
    else
      flash[:error] = "Payment failed. Please try again."
      redirect_to checkout_product_path(@product)
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to checkout_product_path(@product)
  end
end
