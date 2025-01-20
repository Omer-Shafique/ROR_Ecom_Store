module Admin::DashboardHelper
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
      "pending"
    end
  end

  def display_order_actions(order)
    case order.status
    when 'Pending'
      link_to "Mark Fulfilled", fulfill_admin_order_path(order), method: :patch, remote: true, class: "btn btn-success btn-sm"
    when 'Fulfilled'
      link_to "Out for Delivery", out_for_delivery_admin_order_path(order), method: :patch, remote: true, class: "btn btn-primary btn-sm" 
    when 'Out for Delivery'
      link_to "Mark Delivered", delivered_admin_order_path(order), method: :patch, remote: true, class: "btn btn-danger btn-sm"
    when 'Delivered'
      content_tag(:span, "Completed", class: "badge badge-success badge-mature")
    else
      link_to "Mark Fulfilled", fulfill_admin_order_path(order), method: :patch, remote: true, class: "btn btn-success btn-sm"
    end
  end
  
  

  def paginate_orders(orders)
    if orders.respond_to?(:total_pages)
      will_paginate orders, class: 'pagination justify-content-center'
    else
      # 'No orders available'
    end
  end
  
  

  def display_user_actions(user)
    if !user.admin?
      link_to("Make Admin", make_admin_admin_user_path(user), method: :patch, data: { confirm: "Are you sure you want to assign this user as an Admin?" }, class: "btn btn-primary btn-sm mx-1") +
      link_to("Delete User", admin_user_path(user), method: :delete, data: { confirm: "Are you sure you want to delete this user?" }, class: "btn btn-danger btn-sm ml-2")
    else
      content_tag(:span, "Already Admin", style: "color: #ffffff; background-color:rgb(58, 58, 58); padding: 5px 10px; border-radius: 5px; font-size: 14px; font-weight: bold;")
    end
    
  end
end
