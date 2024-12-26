class Product < ApplicationRecord
  belongs_to :user
  validates :product_title, presence: true
  validates :product_description, presence: true
  validates :product_sku, presence: true
  validates :stock_quantity_string, presence: true, numericality: { only_integer: true }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }


  def create_or_update_stripe_product
    stripe_product = Stripe::Product.create({
      name: self.product_title,
      description: self.product_description,
    })
    price = Stripe::Price.create({
      product: stripe_product.id,
      unit_amount: (self.price * 100).to_i, 
      currency: 'usd',
    })
    self.update(stripe_product_id: stripe_product.id, stripe_price_id: price.id)
  end
end
