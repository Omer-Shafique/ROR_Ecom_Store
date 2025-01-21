class ProductDeletionService
  def initialize(product)
    @product = product
  end

  def delete
    if @product.stripe_product_id.present?
      archive_and_delete_stripe_product
    else
      @product.destroy
      true
    end
  end

  private

  def archive_and_delete_stripe_product
    begin
      # Archive the product on Stripe
      Stripe::Product.update(@product.stripe_product_id, active: false)
      @product.destroy
      true
    rescue Stripe::InvalidRequestError => e
      Rails.logger.error("Error archiving product on Stripe: #{e.message}")
      false
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error: #{e.message}")
      false
    end
  end
end
