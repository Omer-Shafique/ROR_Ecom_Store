class AddStripeInventoryQuantityToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :stripe_inventory_quantity, :integer
  end
end
