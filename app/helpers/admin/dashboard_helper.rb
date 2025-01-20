module Admin::DashboardHelper
  # Display order status with conditional rendering
  def display_order_status(status)
    case status
    when 'Pending'
      "Pending"
    when 'Fulfilled'
      "Fulfilled"
    when 'Out for Delivery'
      "Out for Delivery"
    when 'Delivered'
      content_tag(:span, "Completed")
    else
      "Pending"
    end
  end

  # Generate dynamic order actions based on the current status
  def display_order_actions(order)
    case order.status
    when 'Pending'
      link_to "Mark Fulfilled", fulfill_admin_order_path(order), method: :patch, remote: true, class: "btn btn-success btn-sm"
    when 'Fulfilled'
      link_to "Out for Delivery", out_for_delivery_admin_order_path(order), method: :patch, remote: true, class: "btn btn-primary btn-sm" 
    when 'Out for Delivery'
      link_to "Mark Delivered", delivered_admin_order_path(order), method: :patch, remote: true, class: "btn btn-danger btn-sm"
    when 'Delivered'
      content_tag(:span, "Completed", class: "badge badge-success", style: "color: white; background-color: #cf8a00; padding: 5px 10px; border-radius: 5px;")

    else
      link_to "Mark Fulfilled", fulfill_admin_order_path(order), method: :patch, remote: true, class: "btn btn-success btn-sm"
    end
  end

  # Paginate orders with a fallback message if pagination is not applicable
  def paginate_orders(orders)
    if orders.respond_to?(:total_pages)
      will_paginate orders, class: 'pagination justify-content-center'
    else
      content_tag(:p, "No orders available", class: "text-muted text-center")
    end
  end

  # Display actions for user management
  def display_user_actions(user)
    if user.admin?
      content_tag(:span, "Already Admin", style: "color: #ffffff; background-color:rgb(58, 58, 58); padding: 5px 10px; border-radius: 5px; font-size: 14px; font-weight: bold;")
    else
      link_to("Make Admin", make_admin_admin_user_path(user), method: :patch, remote: true, data: { confirm: "Are you sure you want to assign this user as an Admin?" }, class: "btn btn-primary btn-sm mx-1") +
      link_to("Delete User", admin_user_path(user), method: :delete, remote: true, data: { confirm: "Are you sure you want to delete this user?" }, class: "btn btn-danger btn-sm ml-2")
    end
  end
  
end
