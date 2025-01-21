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
