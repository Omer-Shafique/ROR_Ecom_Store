class ProductUpdateService
  def initialize(product, product_params)
    @product = product
    @product_params = product_params
  end

  def update
    if @product.update(@product_params)
      update_stripe_product
      true
    else
      false
    end
  end

  private

  def update_stripe_product
    StripeProductService.new(@product).create_or_update_stripe_product
  end
end
