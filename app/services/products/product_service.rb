module Products
  class ProductService
    def initialize(product, params = {})
    @product = product
    @params = params
    @current_user = @params[:current_user] || (@product.present? ? @product.user : nil)
  end

    # Search products based on query
    def search_products
      if @params[:query].present?
        Product.where("LOWER(product_title) LIKE LOWER(?) OR LOWER(product_description) LIKE LOWER(?)", "%#{@params[:query]}%", "%#{@params[:query]}%")
      else
        Product.all
      end
    end

    def create_stripe_charge
      Stripe::Charge.create(
        amount: (@product.price * 100).to_i,
        currency: 'usd',
        source: @params[:stripeToken],
        description: "Charge for product #{@product.product_title}"
      )
    end

    # Handle successful payment and create order
    def handle_successful_payment(charge)
      if @product.reduce_stripe_quantity
        @order = create_order
        if @order.save
          @order
        else
          false
        end
      else
        false
      end
    end

    def archive_and_destroy_product
      return false unless @product.stripe_product_id.present?

      begin
        stripe_product = Stripe::Product.retrieve(@product.stripe_product_id)

        # Archive the product on Stripe
        archive_successful = Stripe::Product.update(@product.stripe_product_id, active: false)

        if archive_successful
          @product.destroy
          return { success: "Product was successfully deleted from the store and archived on Stripe." }
        else
          return { alert: "Failed to archive product on Stripe. Product not deleted from the store." }
        end
      rescue Stripe::InvalidRequestError => e
        Rails.logger.info "Product not found on Stripe, deleting from the store as well."
        @product.destroy
        return { success: "Product was deleted from the store because it no longer exists on Stripe." }
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe error: #{e.message}"
        return { alert: "There was an error with Stripe, and the product was not archived or deleted." }
      end
    end


    # Create a new order for the product
    def create_order
      Order.new(
        product: @product,
        user: @current_user,  
        total_price: @product.price,
        status: 'pending',
        address: @params[:address],
        phone: @params[:phone],
        location: @params[:location],
        name: @params[:name],
        email: @params[:email]
      )
    end

    # Handle product creation logic
    def create_product
      if @product.save
        @product.create_or_update_stripe_product
        true
      else
        false
      end
    end

    # Handle product update logic
    def update_product(product_params)
      @product.update(product_params)
      @product.create_or_update_stripe_product
      @product.save
    end
  end
end
