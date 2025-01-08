class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy checkout]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :correct_user, only: [:edit, :update, :destroy]
  before_action :authorize_admin!, only: [:new, :create, :edit, :update, :destroy]

  def correct_user
    @product = current_user.products.find_by(id: params[:id])
    redirect_to products_path, notice: "Not authorized to edit this product" if @product.nil?
  end

  def authorize_admin!
    redirect_to products_path, alert: "You are not authorized to perform this action." unless current_user&.admin?
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

  def checkout
    @product = Product.find(params[:id])
    @product.create_or_update_stripe_product
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    token = params[:stripeToken]
    user_name = params[:name]
    user_email = params[:email]
    user_address = params[:address]
    phone = params[:phone]
  
    begin
      charge = Stripe::Charge.create(
        amount: (@product.price * 100).to_i,
        currency: 'usd',
        source: token,
        description: "Charge for product #{@product.product_title}",
        receipt_email: user_email,
        metadata: { 'Name' => user_name, 'Email' => user_email , 'Address' => user_address , 'Phone' => phone }
      )

      # Reduce product quantity in both Stripe and store
      @product.reduce_stripe_quantity

      flash[:success] = "Payment successful!"
      redirect_to thank_you_products_path

    rescue Stripe::CardError => e
      flash[:error] = e.message
      render 'orders/checkout'

    rescue Stripe::StripeError => e
      # flash[:error] = "There was an error processing your payment. Please try again."
      render 'orders/checkout'
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:product_title, :product_description, :product_sku, :stock_quantity_string, :user_id, :price, :stripe_price_id, images: [])
  end
end