class ProductsService
  attr_reader :user, :params

  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def find_product(product_id)
    Product.find_by(id: product_id)
  end

  def fetch_all_products
    Product.all
  end

  def create_product
    product = user.products.build(product_params)
    if product.save
      product.create_or_update_stripe_product
      { redirect_path: product, notice: "Product was successfully created." }
    else
      { redirect_path: new_product_path, alert: "Error creating product." }
    end
  end

  def update_product(product)
    if product.update(product_params)
      product.create_or_update_stripe_product
      { redirect_path: product, notice: "Product was successfully updated." }
    else
      { redirect_path: edit_product_path(product), alert: "Error updating product." }
    end
  end

  def destroy_product(product)
    if product.destroy
      { redirect_path: products_path, notice: "Product was successfully deleted." }
    else
      { redirect_path: products_path, alert: "Error deleting product." }
    end
  end

  def process_checkout(product)
    if process_payment(product)
      product.reduce_stripe_quantity
      { redirect_path: thank_you_products_path, notice: "Payment successful!" }
    else
      { redirect_path: orders_checkout_path, alert: "Payment failed. Please try again." }
    end
  end

  def create_review
    product = find_product(params[:id])
    review = product.reviews.build(review_params)
    review.user = user
    if review.save
      { redirect_path: product_path(product), notice: "Review successfully added!" }
    else
      { redirect_path: product_path(product), alert: "Failed to add review. Please try again." }
    end
  end

  def correct_user_for_product(product)
    product.user == user
  end

  private

  def product_params
    params.require(:product).permit(:product_title, :product_description, :product_sku, :stock_quantity_string, :user_id, :price, :stripe_price_id, images: [])
  end

  def review_params
    params.require(:review).permit(:rating, :content)
  end

  def process_payment(product)
    Stripe::Charge.create(
      amount: (product.price * 100).to_i,
      currency: "usd",
      source: params[:stripeToken],
      description: "Charge for product #{product.product_title}",
      receipt_email: params[:email],
      metadata: { "Name" => params[:name], "Email" => params[:email], "Address" => params[:address], "Phone" => params[:phone] }
    )
    true
  rescue Stripe::CardError => e
    Rails.logger.error "Stripe error while processing payment: #{e.message}"
    false
  end
end
