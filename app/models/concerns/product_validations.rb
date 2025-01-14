module ProductValidations
  extend ActiveSupport::Concern

  included do
    validate :image_limit

    validates :product_title, presence: true
    validates :product_description, presence: true
    validates :product_sku, presence: true
    validates :stock_quantity_string, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  end

  private

  def image_limit
    if images.length > 20
      errors.add(:images, "You can only upload a maximum of 20 images")
    end
  end
end