class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    event = nil

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      head :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      head :bad_request
      return
    end

    case event['type']
    when 'charge.succeeded'
      charge = event['data']['object'] 
      product_title = charge['description']
      product = Product.find_by(product_title: product_title)

      if product
        product.update(stock_quantity_string: product.stock_quantity_string.to_i - 1)
        product.update_stripe_inventory
      end
    end

    head :ok
  end
end
