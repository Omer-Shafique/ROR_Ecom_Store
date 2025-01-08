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
