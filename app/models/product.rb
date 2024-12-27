# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :user

  # Validations for stock_quantity_string being a valid integer string
  validates :product_title, presence: true
  validates :product_description, presence: true
  validates :product_sku, presence: true
  validates :stock_quantity_string, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Convert stock_quantity_string to an integer when interacting with Stripe and other places
  def stock_quantity
    stock_quantity_string.to_i
  end

  def stock_quantity=(value)
    self.stock_quantity_string = value.to_s
  end

  # Create or update Stripe product with stock quantity
  def create_or_update_stripe_product
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
  
    if stripe_price_id.blank? || stripe_product_id.blank?
      stripe_product = Stripe::Product.create(
        name: product_title,
        description: product_description
      )
  
      stripe_price = Stripe::Price.create(
        unit_amount: (price * 100).to_i,
        currency: 'usd',
        product: stripe_product.id
      )
  
      # Update your product with Stripe IDs and quantity
      update(
        stripe_product_id: stripe_product.id,
        stripe_price_id: stripe_price.id,
        stripe_inventory_quantity: stock_quantity
      )
    else
      # Update Stripe product and quantity if it already exists
      Stripe::Product.update(
        stripe_product_id,
        name: product_title,
        description: product_description,
        metadata: { stock_quantity: stock_quantity }
      )
    end
  end

  # Reduce product quantity in Stripe
  def reduce_stripe_quantity
    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    if stripe_product_id.present?
      # Reduce quantity in Stripe (Inventory management)
      Stripe::Product.update(
        stripe_product_id,
        metadata: {
          stock_quantity: stock_quantity - 1
        }
      )

      # Reduce quantity in your store's database
      self.stock_quantity = stock_quantity - 1
      save
    end
  end
end
