# class WishlistsController < ApplicationController
#   before_action :authenticate_user!

#   def index
#     @wishlisted_products = WishlistService.new(current_user).fetch_wishlist
#   end

#   def create
#     product = Product.find(params[:product_id])
#     service = WishlistService.new(current_user)
#     if service.add_to_wishlist(product)
#       redirect_to product_path(product), notice: "Product added to wishlist"
#     else
#       redirect_to product_path(product), alert: "Failed to add product to wishlist"
#     end
#   end

#   def destroy
#     service = WishlistService.new(current_user)
#     if service.remove_from_wishlist(params[:product_id])
#       redirect_to product_path(params[:product_id]), notice: "Product removed from wishlist"
#     else
#       redirect_to product_path(params[:product_id]), alert: "Failed to remove product from wishlist"
#     end
#   end
# end















class WishlistsController < ApplicationController
  before_action :authenticate_user!

  def index
    @wishlisted_products = current_user.wishlist_products
  end

  def create
    product = Product.find(params[:product_id])
    current_user.wishlists.find_or_create_by(product: product)
    redirect_to products_path(product), notice: "Product added to wishlist"
  end

  def destroy
    wishlist = current_user.wishlists.find_by(product_id: params[:product_id])
    wishlist&.destroy
    redirect_to products_path(params[:product_id]), notice: "Product removed from wishlist"
  end
end