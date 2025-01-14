module ProductMethods
  extend ActiveSupport::Concern

  included do
    def stock_quantity
      stock_quantity_string.to_i
    end

    def stock_quantity=(value)
      self.stock_quantity_string = value.to_s
    end
  end
end