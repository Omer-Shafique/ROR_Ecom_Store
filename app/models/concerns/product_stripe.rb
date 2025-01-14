module ProductStripe
  extend ActiveSupport::Concern

  included do
    def create_or_update_stripe_product
      Stripe.api_key = Rails.configuration.stripe[:secret_key]

      if stripe_price_id.blank? || stripe_product_id.blank?
        stripe_product = Stripe::Product.create(
          name: product_title,
          description: product_description
        )
        stripe_price = Stripe::Price.create(
          unit_amount: (price * 100).to_i,
          currency: "usd",
          product: stripe_product.id
        )
        update(
          stripe_product_id: stripe_product.id,
          stripe_price_id: stripe_price.id,
          stripe_inventory_quantity: stock_quantity
        )
      else
        Stripe::Product.update(
          stripe_product_id,
          name: product_title,
          description: product_description,
          metadata: { stock_quantity: stock_quantity }
        )
      end
    end

    def reduce_stripe_quantity
      Stripe.api_key = Rails.configuration.stripe[:secret_key]

      if stripe_product_id.present?
        Stripe::Product.update(
          stripe_product_id,
          metadata: {
            stock_quantity: stock_quantity - 1
          }
        )
        self.stock_quantity = stock_quantity - 1
        save
      end
    end
  end
end
