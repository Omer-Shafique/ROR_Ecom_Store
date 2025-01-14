class WishlistValidator
  attr_reader :errors

  def initialize(product, user)
    @product = product
    @user = user
    @errors = []
  end

  def valid_for_addition?
    validate_product_presence
    validate_product_uniqueness
    errors.empty?
  end

  def valid_for_removal?
    validate_product_presence
    errors.empty?
  end

  private

  def validate_product_presence
    errors << "Product not found" unless @product.present?
  end

  def validate_product_uniqueness
    if @user.wishlists.exists?(product: @product)
      errors << "Product already in wishlist"
    end
  end
end
