module ProductStripe
  extend ActiveSupport::Concern

  included do
    def create_or_update_stripe_product
      Stripe.api_key = Rails.configuration.stripe[:secret_key]
    
      if stripe_price_id.blank? || stripe_product_id.blank?
        # Create the product on Stripe
        stripe_product = Stripe::Product.create(
          name: product_title,
          description: product_description
        )
    
        # Create the price for the product on Stripe
        stripe_price = Stripe::Price.create(
          unit_amount: (price * 100).to_i,
          currency: "usd",
          product: stripe_product.id
        )
    
        # Create the inventory for the product
        Stripe::Product.update(
          stripe_product.id,
          metadata: { stock_quantity: stock_quantity }
        )
    
        # Update the product with stripe IDs and stock quantity
        update(
          stripe_product_id: stripe_product.id,
          stripe_price_id: stripe_price.id,
          stripe_inventory_quantity: stock_quantity
        )
      else
        # Retrieve the existing price from Stripe
        stripe_price = Stripe::Price.retrieve(stripe_price_id)
    
        # Check if the price has changed
        if stripe_price.unit_amount != (price * 100).to_i
          # Update the price on Stripe
          Stripe::Price.update(
            stripe_price_id,
            unit_amount: (price * 100).to_i
          )
    
          # Update the price in the store
          self.update(price: price)
        end
    
        # Update the existing product on Stripe (if other fields have changed)
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
        begin
          stripe_product = Stripe::Product.retrieve(stripe_product_id)
    
          if stripe_product.metadata['stock_quantity'].to_i > 0
            new_stock_quantity = stripe_product.metadata['stock_quantity'].to_i - 1
    
            Stripe::Product.update(
              stripe_product_id,
              metadata: { stock_quantity: new_stock_quantity }
            )
    
            self.update(stock_quantity: new_stock_quantity)
            Rails.logger.info "Product stock reduced by 1 on Stripe and in the store."
    
          else
            raise "Not enough stock on Stripe"
          end
        rescue Stripe::StripeError => e
          Rails.logger.error "Error reducing product quantity on Stripe: #{e.message}"
          errors.add(:base, "There was an issue with reducing the stock quantity on Stripe.")
        end
      else
        Rails.logger.error "Stripe product ID is missing."
        errors.add(:base, "Product is not linked to Stripe.")
      end
    end
    
  end
end
