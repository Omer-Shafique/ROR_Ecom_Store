# class CheckoutController < ApplicationController
#   def new
#     @product = Product.find(params[:product_id])
#     @product_title = @product.title
#   end

#   def create
#     @product = Product.find(params[:product_id])
#     @amount = (@product.price * 100).to_i  # Amount in cents

#     # Create a PaymentIntent with the order amount and currency
#     payment_intent = Stripe::PaymentIntent.create({
#       amount: @amount,
#       currency: 'usd',
#       metadata: { product_id: @product.id }
#     })

#     # Store the payment intent client secret in the form
#     @client_secret = payment_intent.client_secret
#   end

#   def stripe_webhook
#     payload = request.body.read
#     sig_header = request.env['HTTP_STRIPE_SIGNATURE']
#     event = nil

#     begin
#       event = Stripe::Webhook.construct_event(
#         payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET']
#       )
#     rescue JSON::ParserError => e
#       status 400
#       return
#     rescue Stripe::SignatureVerificationError => e
#       status 400
#       return
#     end

#     # Handle successful payment
#     if event['type'] == 'payment_intent.succeeded'
#       payment_intent = event['data']['object'] # Contains a Stripe::PaymentIntent

#       # Retrieve product details from metadata
#       product_id = payment_intent['metadata']['product_id']
#       product = Product.find(product_id)

#       # Update the stock of the product in the database
#       if product.stock_quantity > 0
#         product.update(stock_quantity: product.stock_quantity - 1)
#       end
#     end

#     # Acknowledge receipt of the event
#     head :ok
#   end
# end
