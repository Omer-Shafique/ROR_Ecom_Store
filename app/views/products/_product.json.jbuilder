json.extract! product, :id, :product_title, :product_description, :product_sku, :stock_quantity_string, :created_at, :updated_at
json.url product_url(product, format: :json)
