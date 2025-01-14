module Admin::AdminDashboardHelper
  def format_user_role(user)
    user.admin? ? 'Admin' : 'User'
  end

  def formatted_order_status(order)
    order.status.capitalize
  end
end
