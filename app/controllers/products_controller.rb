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
    if @product.destroy
      begin
        Stripe::Product.delete(@product.stripe_product_id)
        flash[:success] = "Product was successfully deleted from the store and Stripe."
      rescue Stripe::StripeError => e
        flash[:alert] = "Product was deleted from the store, but there was an issue deleting it from Stripe: #{e.message}"
      end
      redirect_to products_path, notice: "Product was successfully deleted."
    else
      redirect_to products_path, alert: "Product could not be deleted."
    end
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












































# class ProductsController < ApplicationController
#   include UserAuthorizable
#   include ProductManagement

#   before_action :set_product, only: %i[show edit update destroy checkout]
#   before_action :authenticate_user!, except: [:index, :show]

#   def index
#     @products = Product.all
#   end

#   def show
#     @products = Product.where(user: current_user)
#   end

#   def new
#     @product = current_user.products.build
#   end

#   def edit; end

#   def create
#     @product = current_user.products.build(product_params)

#     if @product.save
#       @product.create_or_update_stripe_product
#       redirect_to @product, notice: "Product was successfully created."
#     else
#       render :new
#     end
#   end

#   def update
#     if @product.update(product_params)
#       @product.create_or_update_stripe_product
#       redirect_to @product, notice: "Product was successfully updated."
#     else
#       render :edit
#     end
#   end

#   def destroy
#     if @product.destroy
#       redirect_to products_path, notice: "Product was successfully deleted."
#     else
#       redirect_to products_path, alert: "Product could not be deleted."
#     end
#   end

#   def checkout
#     return render 'orders/checkout' if params[:stripeToken].blank?

#     stripe_payment_service = StripePaymentService.new(@product, params[:stripeToken], checkout_params)

#     begin
#       # Process the payment and create the order
#       charge = stripe_payment_service.create_order_and_process_payment
#       handle_successful_payment(charge)
#     rescue Stripe::CardError => e
#       flash[:error] = e.message
#       render 'orders/checkout'
#     end
#   end

#   private

#   def handle_successful_payment(charge)
#     @product.reduce_stripe_quantity
#     flash[:success] = "Payment successful!"

#     @order = OrderCreationService.new(@product, current_user, checkout_params).create_order
#     if @order.save
#       redirect_to order_path(@order)
#     else
#       flash[:error] = "Order creation failed."
#       render 'orders/checkout'
#     end
#   end

#   def checkout_params
#     params.permit(:address, :phone, :location, :name, :email)
#   end
# end










































