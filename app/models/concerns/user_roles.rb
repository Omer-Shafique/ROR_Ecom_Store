module UserRoles
  extend ActiveSupport::Concern

  included do
    def admin?
      role == "admin"
    end

    def normal_user?
      role == "normal"
    end
  end
end
