class Product < ApplicationRecord
  include ProductValidations
  include ProductAssociations
  include ProductMethods
  include ProductStripe
  include PgSearch::Model
  pg_search_scope :search_by_name, against: :product_title
end
