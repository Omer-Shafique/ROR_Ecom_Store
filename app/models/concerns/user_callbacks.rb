module UserCallbacks
  extend ActiveSupport::Concern

  included do
    before_validation :set_default_role
  end

  private

  def set_default_role
    self.role ||= "normal"
  end
end