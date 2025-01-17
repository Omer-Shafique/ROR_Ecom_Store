module UserAssociations
  extend ActiveSupport::Concern

  included do
    has_many :wishlists , dependent: :destroy
    has_many :likes, dependent: :destroy
    has_many :wishlist_products
    has_many :products
    has_many :orders
    has_many :reviews, dependent: :destroy
    has_many :wishlists, dependent: :destroy
    has_many :products, through: :wishlist_products
    has_many :comments, dependent: :destroy 
  end
end