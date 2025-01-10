# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :address, presence: true
  validates :phone, presence: true
  validates :status, inclusion: { in: %w[pending processing fulfilled canceled] }
  validates :product, :user, :total_price, :address, :phone, presence: true
end
