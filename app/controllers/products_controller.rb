# class ProductsController < ApplicationController
#   include UserAuthorizable

#   before_action :set_product, only: %i[show edit update destroy checkout]
#   before_action :authenticate_user!, except: [:index, :show]

#   def index
#     @products = Product.all
#   end

#   def show
#     @product = Product.find(params[:id])
#     @reviews = @product.reviews.includes(:user, :comments, :likes)
#   end

#   def new
#     @product = current_user.products.build
#   end

#   def edit
#   end

#   def create
#     service = ProductManagementService.new(current_user, product_params)
#     @product = service.create

#     if @product
#       redirect_to @product, notice: "Product was successfully created."
#     else
#       render :new
#     end
#   end

#   def update
#     service = ProductManagementService.new(current_user, product_params)
#     @product = service.update(@product)

#     if @product
#       redirect_to @product, notice: "Product was successfully updated."
#     else
#       render :edit
#     end
#   end

#   def destroy
#     service = ProductManagementService.new(current_user, product_params)
#     service.destroy(@product)

#     redirect_to products_path, notice: "Product was successfully deleted."
#   end

#   def checkout
#     stripe_token = params[:stripeToken]
#     order_params = {
#       user_id: current_user.id,
#       address: params[:address],
#       phone: params[:phone]
#     }

#     payment_service = StripePaymentService.new(@product, stripe_token, order_params)

#     begin
#       @order = payment_service.process_payment
#       redirect_to order_path(@order), notice: "Payment successful!"
#     rescue Stripe::CardError => e
#       flash[:error] = e.message
#       render 'orders/checkout'
#     end
#   end

#   private

#   def set_product
#     @product = Product.find(params[:id])
#   end

#   def product_params
#     params.require(:product).permit(:product_title, :product_description, :product_sku, :stock_quantity_string, :user_id, :price, :stripe_price_id)
#   end
# end










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
    # @reviews = @product.reviews
  end
  

  # def show
  #   @products = Product.where(user: current_user)
  # end

  def show
    @product = Product.find(params[:id])
    @reviews = @product.reviews.includes(:user, :comments, :likes) # Preload associations for performance
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

  def checkout
    @product = Product.find(params[:id]) # Ensure @product is loaded correctly.
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    token = params[:stripeToken]
  
    if token.blank?
      # flash[:error] = "Stripe token is missing."
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
  
      # Ensure @order is either fetched or created
      # Assuming you want to fetch the order using the current user and product
      @order = Order.find_by(product_id: @product.id, user_id: current_user.id)
  
      # Debugging: log the order to see if it's found correctly
      Rails.logger.info "Order found: #{@order.inspect}"
  
      if @order.nil?
        # If no order is found, create a new one
        @order = Order.create(
          product: @product,
          user: current_user,
          total_price: @product.price,
          status: 'pending',
          address: params[:address],
          phone: params[:phone]
          


        )
  
        # Debugging: log new order creation
        Rails.logger.info "New Order created: #{@order.inspect}"
      end
  
      # Ensure @order is persisted before redirect
      if @order.persisted?
        redirect_to order_path(@order)
      else
        flash[:error] = "Order creation failed."
        render 'orders/checkout'
      end
  
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
    params.require(:product).permit(
      :product_title,
      :product_description,
      :product_sku,
      :stock_quantity_string,
      :user_id,
      :price,
      :stripe_price_id,
      images: [] 
    )
  end
end