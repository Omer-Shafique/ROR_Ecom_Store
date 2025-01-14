class InventoryService
  def self.update_inventory(product, quantity_change)
    product.update!(stock_quantity_string: product.stock_quantity_string.to_i + quantity_change)
    product.sync_stripe_inventory
  end
end
