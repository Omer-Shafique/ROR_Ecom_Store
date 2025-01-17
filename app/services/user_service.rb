class UserService
  def initialize(user)
    @user = user
  end

  def delete_user
    if @user.admin?
      { success: false, message: "You cannot delete an admin user." }
    elsif @user.destroy
      { success: true, message: "User has been deleted." }
    else
      { success: false, message: "Failed to delete user." }
    end
  end

  def promote_to_admin
    if @user.admin?
      { success: false, message: "This user is already an admin." }
    elsif @user.update(admin: true)
      { success: true, message: "User has been promoted to Admin." }
    else
      { success: false, message: "Failed to promote user." }
    end
  end
end
