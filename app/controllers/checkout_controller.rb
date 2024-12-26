class CheckoutController < ApplicationController
  before_action :set_product, only: [:new, :create]

  def new
  end

  def create
    @stripe_token = params[:stripeToken]
    @product = Product.find(params[:product_id])
  
    begin
      charge = Stripe::Charge.create({
        amount: (@product.price * 100).to_i, 
        currency: 'usd',
        source: @stripe_token,
        description: @product.title,
      })

      if charge.status == 'succeeded'
        @product.update(stock_quantity: @product.stock_quantity_string.to_i - 1)
        update_stripe_inventory(@product)
        flash[:success] = "Payment Successful. Thank you for your purchase!"

      else
        flash[:error] = "Payment failed. Please try again."
        render :new
      end
    rescue Stripe::CardError => e
      flash[:error] = e.message
      render :new
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def update_stripe_inventory(product)
    begin
      stripe_product = Stripe::Product.retrieve(product.stripe_product_id)
      stripe_product.inventory = { available_quantity: product.stock_quantity }
      stripe_product.save
    rescue Stripe::InvalidRequestError => e
      Stripe::Product.create({
        name: product.title,
        description: product.description,
        type: 'good',
        active: true
      })
    end
  end
end
