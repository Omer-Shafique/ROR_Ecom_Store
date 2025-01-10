class User < ApplicationRecord
  # Include default Devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :wishlists
  has_many :wishlist_products, through: :wishlists, source: :product
  has_many :products
  has_many :orders

  # Validations
  validates :role, inclusion: { in: %w[admin normal], message: "%{value} is not a valid role" }

  # Callbacks
  before_validation :set_default_role

  # Role Check Methods
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
