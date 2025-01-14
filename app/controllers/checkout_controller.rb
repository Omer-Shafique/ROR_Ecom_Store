class CheckoutController < ApplicationController
  include ProductFinder

  def new
  end

  def create
    @stripe_token = params[:stripeToken]

    begin
      charge = StripePaymentService.new(@product, @stripe_token).process_payment

      if PaymentValidator.successful?(charge)
        InventoryService.update_inventory(@product, -1)
        FlashMessageService.success!(flash, "Payment Successful. Thank you for your purchase!")
        redirect_to order_path(@order)
      else
        FlashMessageService.error!(flash, "Payment failed. Please try again.")
        render :new
      end
    rescue Stripe::CardError => e
      FlashMessageService.error!(flash, e.message)
      render :new
    end
  end
end












# class CheckoutController < ApplicationController
#   before_action :set_product, only: [:new, :create]

#   def new
#   end

#   def create
#     @stripe_token = params[:stripeToken]
#     begin
#       charge = Stripe::Charge.create({
#         amount: (@product.price * 100).to_i,
#         currency: 'usd',
#         source: @stripe_token,
#         description: @product.title
#       })

#       if charge.status == 'succeeded'
#         update_inventory(@product, -1)
#         flash[:success] = "Payment Successful. Thank you for your purchase!"
#         # redirect_to product_path(@product)
#          redirect_to order_path(@order)
#       else
#         flash[:error] = "Payment failed. Please try again."
#         render :new
#       end
#     rescue Stripe::CardError => e
#       flash[:error] = e.message
#       render :new
#     end
#   end

#   private

#   def set_product
#     @product = Product.find(params[:product_id])
#   end

#   def update_inventory(product, quantity_change)
#     product.update!(stock_quantity_string: product.stock_quantity_string.to_i + quantity_change)
#     product.sync_stripe_inventory
#   end
# end
