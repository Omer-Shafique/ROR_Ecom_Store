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
  end

  def new
    @product = current_user.products.build
  end

  def edit
  end

  def create
    @product = current_user.products.build(product_params)
    if @product.save
      redirect_to @product, notice: "Product was successfully created."
    else
      render :new
    end
  end

  def update
    if @product.update(product_params)
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

  # Direct Checkout action
  def checkout
    @product = Product.find(params[:id])

    # Set your secret key for Stripe
    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    # Create the Stripe charge on form submission
    token = params[:stripeToken]

    begin
      # Create the charge with the Stripe token
      charge = Stripe::Charge.create(
        amount: (@product.price * 100).to_i,  # Convert price to cents
        currency: 'usd',                     # Adjust currency as needed
        source: token,                       # Use the token from the form
        description: "Charge for product #{@product.product_title}"
      )

      # Handle success
      flash[:success] = "Payment was successful!"
      redirect_to product_path(@product)

    rescue Stripe::CardError => e
      # Handle card errors like card declines
      flash[:error] = e.message
      # render :checkout

    rescue Stripe::StripeError => e
      # Handle other Stripe API errors
      flash[:error] = "There was an error processing your payment. Please try again."
      render 'orders/checkout'
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:product_title, :product_description, :product_sku, :stock_quantity_string, :user_id, :price)
  end
end