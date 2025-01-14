module UserValidations
  extend ActiveSupport::Concern

  included do
    validates :role, inclusion: { in: %w[admin normal], message: "%{value} is not a valid role" }
  end
end