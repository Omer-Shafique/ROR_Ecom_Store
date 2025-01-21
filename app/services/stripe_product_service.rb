class StripeProductService
  def initialize(product)
    @product = product
  end

  def create_or_update_stripe_product
    if @product.stripe_product_id.present?
      # Update product on Stripe if exists
      update_stripe_product
    else
      # Create new product on Stripe
      create_stripe_product
    end
  end

  private

  def create_stripe_product
    stripe_product = Stripe::Product.create(
      name: @product.product_title,
      description: @product.product_description,
      metadata: { "product_sku" => @product.product_sku }
    )

    @product.update(stripe_product_id: stripe_product.id)
  end

  def update_stripe_product
    Stripe::Product.update(@product.stripe_product_id, 
      name: @product.product_title,
      description: @product.product_description
    )
  end
end
