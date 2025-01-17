module UserAuthorizable
  extend ActiveSupport::Concern

  included do
    before_action :correct_user, only: [:edit, :update, :destroy]
  end

  private

  def correct_user
    @product = current_user.products.find_by(id: params[:id])
    
    # Check if the current user is an admin or the owner of the product
    if @product.nil? || (!current_user.admin? && @product.user != current_user)
      redirect_to products_path, notice: "Not authorized to edit this product"
    end
  end
  
  
end
