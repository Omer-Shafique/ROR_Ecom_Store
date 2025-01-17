class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :user_id, uniqueness: { scope: :product_id }
  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  def cannot_like_own_review
    errors.add(:base, "You cannot like your own review.") if user == product.user
  end
end
