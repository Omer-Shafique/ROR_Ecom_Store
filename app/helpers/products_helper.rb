module ProductsHelper
  def carousel_items(product)
    if product.images.attached?
      product.images.map.with_index do |image, index|
        content_tag(:div, class: "carousel-item #{'active' if index.zero?}") do
          image_tag(image, alt: product.product_title, class: "d-block w-100 carousel-image")
        end
      end.join.html_safe
    else
      content_tag(:div, class: "carousel-item active") do
        image_tag("https://via.placeholder.com/600x400?text=No+Image+Available", alt: "No Image", class: "d-block w-100")
      end
    end
  end

  def formatted_user_name(user)
    user.first_name.present? && user.last_name.present? ? "#{user.first_name} #{user.last_name}" : 'Anonymous'
  end

  def formatted_price(product)
    product.price.present? ? "$#{product.price}" : "N/A"
  end

  def formatted_stock(product)
    product.stock_quantity_string.present? ? product.stock_quantity_string : "2"
  end

  def render_product_image(product)
    if product.images.attached?
      product.images.map do |image|
        image_tag(image, alt: product.product_title, class: "img-fluid", size: "100x100")
      end.join.html_safe
    else
      "No Image"
    end
  end

  def render_stock_status(product)
    if product.stock_quantity > 0
      link_to "Buy Now", checkout_product_path(product), class: "btn btn-success btn-sm shadow-sm mx-1 my-2", data: { turbo: false }
    else
      content_tag(:span, "Out of Stock", class: "btn btn-secondary btn-sm mx-1 my-2")
    end
  end

  def render_admin_actions(product)
    safe_join([
      link_to("Edit", edit_product_path(product), class: "btn btn-warning btn-sm shadow-sm mx-1 my-2"),
      link_to("Delete", product_path(product), method: :delete, data: { confirm: "Are you sure?" }, class: "btn btn-danger btn-sm shadow-sm mx-1")
    ])
  end

  def render_user_actions(product)
    safe_join([
      render_stock_status(product),
      link_to("Add to Wishlist", product_wishlist_path(product), method: :post, class: "btn btn-danger btn-sm shadow-sm mx-1")
    ])
  end
end
