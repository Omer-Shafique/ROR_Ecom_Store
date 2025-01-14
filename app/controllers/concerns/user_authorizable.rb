module UserAuthorizable
  extend ActiveSupport::Concern

  included do
    before_action :correct_user, only: [:edit, :update, :destroy]
  end

  private

  def correct_user
    @product = current_user.products.find_by(id: params[:id])
    redirect_to products_path, notice: "Not authorized to edit this product" if @product.nil?
  end
end
