class CheckoutService
  def initialize(product, user_name, user_email, stripe_token)
    @product = product
    @user_name = user_name
    @user_email = user_email
    @stripe_token = stripe_token
  end

  def process_checkout
    image_url = fetch_product_image_url

    charge = Stripe::Charge.create(
      amount: (@product.price * 100).to_i,
      currency: "usd",
      description: "#{@product.product_title} - #{image_url}",
      source: @stripe_token,
      receipt_email: @user_email,
      metadata: { "Name" => @user_name, "Email" => @user_email, "Product Image" => image_url }
    )

    charge.paid
  end

  private

  def fetch_product_image_url
    @product.images.attached? ? Rails.application.routes.url_helpers.rails_blob_path(@product.images.first, only_path: true) : nil
  end
end
