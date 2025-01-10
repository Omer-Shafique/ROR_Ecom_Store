class Like < ApplicationRecord
  belongs_to :review
  belongs_to :user

  validates :user_id, uniqueness: { scope: :review_id, message: "You can only like a review once" }
end
