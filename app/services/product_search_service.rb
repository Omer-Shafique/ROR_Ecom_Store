class ProductSearchService
  def initialize(query = nil)
    @query = query
  end

  def search
    if @query.present?
      Product.where("LOWER(product_title) LIKE LOWER(?) OR LOWER(product_description) LIKE LOWER(?)", "%#{@query}%", "%#{@query}%")
    else
      Product.all
    end
  end
end
