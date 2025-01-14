module ProductAssociations
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    has_many_attached :images
    has_many :wishlists, dependent: :destroy
    has_many :reviews, dependent: :destroy
    has_many :users_who_wishlisted, through: :wishlists, source: :user
  end
end