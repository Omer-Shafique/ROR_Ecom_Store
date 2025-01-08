class User < ApplicationRecord
  # Include default Devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :wishlists
  has_many :wishlist_products, through: :wishlists, source: :product
  has_many :products
  validates :role, inclusion: { in: %w[admin normal], message: "%{value} is not a valid role" }
  before_save :set_default_role

  def admin?
    role == "admin"
  end

  def normal_user?
    role == "normal"
  end

  private

  def set_default_role
    self.role ||= "normal"
  end
end
