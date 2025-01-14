class ProductManagementService
  def initialize(user, product_params)
    @user = user
    @product_params = product_params
  end

  def create
    product = @user.products.build(@product_params)
    if product.save
      product.create_or_update_stripe_product
      product
    else
      nil
    end
  end

  def update(product)
    if product.update(@product_params)
      product.create_or_update_stripe_product
      product
    else
      nil
    end
  end

  def destroy(product)
    product.destroy
  end
end
