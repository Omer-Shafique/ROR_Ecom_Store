module ReviewAuthorization
  extend ActiveSupport::Concern

  def authorized_to_delete?(review)
    current_user == review.user || current_user.admin?
  end
end
