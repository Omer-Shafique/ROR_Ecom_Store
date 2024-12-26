class Order < ApplicationRecord
  
  belongs_to :user
  belongs_to :product

  validates :name, :email, :phone, :address, presence: true
end
