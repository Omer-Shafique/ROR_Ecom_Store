class AddProductIdToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :product, null: false, foreign_key: true
  end
end
