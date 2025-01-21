class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy checkout]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    if params[:query].present?
      @products = Product.where("LOWER(product_title) LIKE LOWER(?) OR LOWER(product_description) LIKE LOWER(?)", "%#{params[:query]}%", "%#{params[:query]}%")

    else
      @products = Product.all
    end
  end

  def show
    @products = Product.where(user: current_user)
    @review = @product.reviews.first
  end

  def new
    @product = current_user.products.build
  end

  def search
    @products = Product.where("product_title ILIKE ?", "%#{params[:query]}%")
    respond_to do |format|
      format.js  
      format.html
    end
  end

  
  def edit; end

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
    if @product.stripe_product_id.present?
      begin
        # Check if the product exists on Stripe
        Stripe::Product.retrieve(@product.stripe_product_id)
        
        # Archive the product on Stripe by setting active to false
        archive_successful = Stripe::Product.update(@product.stripe_product_id, active: false)
  
        if archive_successful
          @product.destroy
          flash[:success] = "Product was successfully deleted from the store and archived on Stripe."
        else
          flash[:alert] = "Failed to archive product on Stripe. Product not deleted from the store."
        end
      rescue Stripe::InvalidRequestError => e
        # If the product is not found on Stripe (deleted manually), remove it from the store
        Rails.logger.info "Product not found on Stripe, deleting from the store as well."
        @product.destroy
        flash[:success] = "Product was deleted from the store because it no longer exists on Stripe."
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe error: #{e.message}"
        flash[:alert] = "There was an error with Stripe, and the product was not archived or deleted."
      end
    else
      flash[:alert] = "Stripe product ID is missing or invalid."
    end
    redirect_to products_path
  end
  
  

  def checkout
    if params[:stripeToken].blank?
      render 'orders/checkout' and return
    end

    begin
      charge = create_stripe_charge
      handle_successful_payment(charge)
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
    params.require(:product).permit(:product_title, :product_description, :product_sku, :stock_quantity_string, :user_id, :price, :stripe_price_id, images: [])
  end


  def create_stripe_charge
    Stripe::Charge.create(
      amount: (@product.price * 100).to_i,
      currency: 'usd',
      source: params[:stripeToken],
      description: "Charge for product #{@product.product_title}"
    )
  end

  def handle_successful_payment(charge)
    @product.reduce_stripe_quantity
    flash[:success] = "Payment successful!"

    @order = create_order
    if @order.save
      redirect_to order_path(@order)
    else
      flash[:error] = "Order creation failed."
      render 'orders/checkout'
    end
  end

  def create_order
    Order.new(
      product: @product,
      user: current_user,
      total_price: @product.price,
      status: 'pending',
      address: params[:address],
      phone: params[:phone],
      location: params[:location],
      name: params[:name],
      email: params[:email]
    )
  end

  private

  def correct_user
    @product = Product.find(params[:id])
    redirect_to root_url, notice: "Not authorized" unless @product.user == current_user
  end

end