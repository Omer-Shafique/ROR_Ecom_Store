class OrderFulfillmentService
  def initialize(order)
    @order = order
  end

  def fulfill
    if @order.update(status: 'fulfilled')
      true
    else
      false
    end
  end
end
