class AddStripeFieldsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :stripe_price_id, :string
  end
end
