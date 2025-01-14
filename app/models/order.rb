class Order < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :address, presence: true
  validates :phone, presence: true
  validates :status, inclusion: { in: ['Pending', 'Fulfilled', 'Out for Delivery', 'Delivered'] }
  validates :product, :user, :total_price, :address, :phone, presence: true
end