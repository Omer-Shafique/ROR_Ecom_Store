class OrderCreationService
  def initialize(product, user, params)
    @product = product
    @user = user
    @params = params
  end

  def create_order
    Order.new(
      product: @product,
      user: @user,
      total_price: @product.price,
      status: 'pending',
      address: @params[:address],
      phone: @params[:phone],
      location: @params[:location],
      name: @params[:name],
      email: @params[:email]
    )
  end
end
