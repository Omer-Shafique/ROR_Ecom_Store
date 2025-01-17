class AddCascadeDeleteToOrders < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :orders, :products
    add_foreign_key :orders, :products, on_delete: :cascade
  end
end
