class WishlistsService
  attr_reader :user, :product_id, :redirect_path

  def initialize(user, product_id, redirect_path)
    @user = user
    @product_id = product_id
    @redirect_path = redirect_path
  end

  def add_to_wishlist
    product = Product.find(product_id)
    wishlist = user.wishlists.find_or_create_by(product: product)

    if wishlist.persisted?
      { flash_key: :notice, message: "Product added to wishlist", redirect_path: redirect_path }
    else
      { flash_key: :error, message: "Failed to add product to wishlist", redirect_path: redirect_path }
    end
  end

  def remove_from_wishlist
    wishlist = user.wishlists.find_by(product_id: product_id)
    if wishlist&.destroy
      { flash_key: :notice, message: "Product removed from wishlist", redirect_path: redirect_path }
    else
      { flash_key: :error, message: "Failed to remove product from wishlist", redirect_path: redirect_path }
    end
  end
end
