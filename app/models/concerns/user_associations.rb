module UserAssociations
  extend ActiveSupport::Concern

  included do
    has_many :wishlists
    has_many :wishlist_products, through: :wishlists, source: :product
    has_many :products
    has_many :orders
    has_many :reviews, dependent: :destroy
  end
end