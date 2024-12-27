class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error("Stripe webhook error: #{e.message}")
      head :bad_request
      return
    end

    case event['type']
    when 'charge.succeeded'
      charge = event['data']['object']
      product = Product.find_by(title: charge['description'])
      product.update!(stock_quantity_string: product.stock_quantity_string.to_i - 1) if product
    end

    head :ok
  end
end
