# app/controllers/admin/products_controller.rb
class Admin::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @products = Product.all  # Fetch all products for admin
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_path, notice: 'Product created successfully.'
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to admin_products_path, notice: 'Product updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to admin_products_path, notice: 'Product deleted successfully.'
  end

  private

  def product_params
    params.require(:product).permit(:title, :description, :price, :image)
  end

  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
end
