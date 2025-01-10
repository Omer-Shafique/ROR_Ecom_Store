class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review, only: [:destroy, :like]

  def create
    service = ReviewsService.new(current_user, params)
    result = service.create_review
    redirect_to result[:redirect_path], notice: result[:notice], alert: result[:alert]
  end

  def destroy
    service = ReviewsService.new(current_user, params)
    result = service.destroy_review(@review)
    redirect_to result[:redirect_path], notice: result[:notice], alert: result[:alert]
  end

  def like
    service = ReviewsService.new(current_user, params)
    result = service.like_review(@review)
    redirect_to result[:redirect_path], notice: result[:notice], alert: result[:alert]
  end

  private

  def set_review
    @review = ReviewsService.new(current_user, params).find_review(params[:id])
    redirect_to products_path, alert: "Review not found." unless @review
  end

  def review_params
    params.require(:review).permit(:product_id, :rating, :content)
  end
end
