class Product < ApplicationRecord
  include ProductValidations
  include ProductAssociations
  include ProductMethods
  include ProductStripe
  include PgSearch::Model
  pg_search_scope :search_by_name, against: :product_title
end













# # app/models/product.rb
# class Product < ApplicationRecord
#   belongs_to :user
#   has_many_attached :images
#   has_many :wishlists, dependent: :destroy
#   has_many :reviews, dependent: :destroy
#   has_many :users_who_wishlisted, through: :wishlists, source: :user
#   validate :image_limit
#   validates :product_title, presence: true
#   validates :product_description, presence: true
#   validates :product_sku, presence: true
#   validates :stock_quantity_string, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
#   validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }


#   def image_limit
#     if images.length > 20
#       error.add(:images, "You can only upload a maximum of 20 images")
#     end
#   end

#   def stock_quantity
#     stock_quantity_string.to_i
#   end

#   def stock_quantity=(value)
#     self.stock_quantity_string = value.to_s
#   end



#   # goto stripe concern
#   def create_or_update_stripe_product
#     Stripe.api_key = Rails.configuration.stripe[:secret_key]
#     if stripe_price_id.blank? || stripe_product_id.blank?
#       stripe_product = Stripe::Product.create(
#         name: product_title,
#         description: product_description
#       )
#       stripe_price = Stripe::Price.create(
#         unit_amount: (price * 100).to_i,
#         currency: "usd",
#         product: stripe_product.id
#       )
#       update(
#         stripe_product_id: stripe_product.id,
#         stripe_price_id: stripe_price.id,
#         stripe_inventory_quantity: stock_quantity
#       )
#     else
#       Stripe::Product.update(
#         stripe_product_id,
#         name: product_title,
#         description: product_description,
#         metadata: { stock_quantity: stock_quantity }
#       )
#     end
#   end
#   def reduce_stripe_quantity
#     Stripe.api_key = Rails.configuration.stripe[:secret_key]

#     if stripe_product_id.present?
#       Stripe::Product.update(
#         stripe_product_id,
#         metadata: {
#           stock_quantity: stock_quantity - 1
#         }
#       )
#       self.stock_quantity = stock_quantity - 1
#       save
#     end
#   end
# end
