
class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy checkout]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def correct_user
    @product = current_user.products.find_by(id: params[:id])
    redirect_to products_path, notice: "Not authorized to edit this product" if @product.nil?
  end

  def index
    @products = Product.all
  end

  def show
    @products = Product.where(user: current_user)
  end

  def new
    @product = current_user.products.build
  end

  def edit
  end

  def thank_you
    @order = current_user.orders.last
  
    # Debugging: Log the order to verify it's being fetched
    Rails.logger.info "Order fetched: #{@order.inspect}"
  
    # Redirect if no order is found
    unless @order
      redirect_to root_path, alert: "Something went wrong. Please contact support."
    end
  end
  

  def create
    @product = current_user.products.build(product_params)
    if @product.save
      @product.create_or_update_stripe_product
      redirect_to @product, notice: "Product was successfully created."
    else
      render :new
    end
  end

  def update
    if @product.update(product_params)
      @product.create_or_update_stripe_product
      redirect_to @product, notice: "Product was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    if @product.destroy
      redirect_to products_path, notice: "Product was successfully deleted."
    else
      redirect_to products_path, alert: "Product could not be deleted."
    end
  end

  # def checkout
  #   @product = Product.find(params[:id])
  #   @product.create_or_update_stripe_product
  #   Stripe.api_key = Rails.configuration.stripe[:secret_key]
  #   token = params[:stripeToken]

  #   begin
  #     charge = Stripe::Charge.create(
  #       amount: (@product.price * 100).to_i,
  #       currency: 'usd',
  #       source: token,
  #       description: "Charge for product #{@product.product_title}"
  #     )

  #     # Reduce product quantity in both Stripe and store
  #     @product.reduce_stripe_quantity

  #     flash[:success] = "Payment successful!"
  #     # redirect_to product_path(@product)
  #     # redirect_to thank_you_products_path
  #     redirect_to order_path(@order)

  #   rescue Stripe::CardError => e
  #     flash[:error] = e.message

  #   rescue Stripe::StripeError => e
  #     # flash[:error] = "There was an error processing your payment. Please try again."
  #     render 'orders/checkout'
  #   end
  # end
  


  def checkout
    @product = Product.find(params[:id])
    @product.create_or_update_stripe_product
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    token = params[:stripeToken]
  
    if token.blank?
      flash[:error] = "Stripe token is missing."
      render 'orders/checkout' and return
    end
  
    begin
      charge = Stripe::Charge.create(
        amount: (@product.price * 100).to_i,
        currency: 'usd',
        source: token,
        description: "Charge for product #{@product.product_title}"
      )
  
      # Reduce product quantity in both Stripe and store
      @product.reduce_stripe_quantity
  
      flash[:success] = "Payment successful!"
      
      # Create the order here as well
      @order = Order.create(
        product: @product,
        user: current_user,
        total_price: @product.price
      )
  
      redirect_to order_path(@order)
  
    rescue Stripe::CardError => e
      flash[:error] = e.message
      render 'orders/checkout'
    end
  end
  
  
  
  

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:product_title, :product_description, :product_sku, :stock_quantity_string, :user_id, :price, :stripe_price_id)
  end
end