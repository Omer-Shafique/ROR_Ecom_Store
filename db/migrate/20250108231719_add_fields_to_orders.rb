class AddFieldsToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :customer_name, :string unless column_exists?(:orders, :customer_name)
    add_column :orders, :status, :string unless column_exists?(:orders, :status)
  end
end
