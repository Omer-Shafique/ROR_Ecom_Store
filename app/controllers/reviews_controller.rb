class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review, only: [:destroy, :like]

  def index
    @reviews = Review.all
  end

  def create
    @product = Product.find(params[:product_id])
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to @product, notice: 'Review was successfully created.'
    else
      flash[:alert] = 'Failed to create review. Please correct the errors below.'
      redirect_to @product 
    end
  end

  def destroy
    if current_user == @review.user || current_user.admin?
      @review.destroy
      redirect_to product_path(@review.product), notice: "Review deleted successfully."
    else
      redirect_to product_path(@review.product), alert: "You are not authorized to delete this review."
    end
  end

  def like
    @like = @review.likes.new(user: current_user)

    if @like.save
      redirect_to product_path(@review.product), notice: "You liked this review."
    else
      redirect_to product_path(@review.product), alert: "You can only like a review once."
    end
  end

  private

  def set_review
    @review = Review.find_by(id: params[:id])
    redirect_to products_path, alert: "Review not found." unless @review
  end

  def review_params
    params.require(:review).permit(:product_id, :rating, :content)
  end
end