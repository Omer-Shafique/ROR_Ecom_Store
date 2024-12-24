class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :product_title
      t.string :product_description
      t.string :product_sku
      t.string :stock_quantity_string

      t.timestamps
    end
  end
end
