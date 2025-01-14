class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :user_id, uniqueness: { scope: :product_id }

  def cannot_like_own_review
    errors.add(:base, "You cannot like your own review.") if user == product.user
  end
end
