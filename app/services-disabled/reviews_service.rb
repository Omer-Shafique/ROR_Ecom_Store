class ReviewsService
  attr_reader :user, :params

  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def create_review
    review = user.reviews.new(review_params)
    if review.save
      { redirect_path: review.product, notice: "Review added successfully." }
    else
      { redirect_path: review.product, alert: "Failed to add review." }
    end
  end

  def destroy_review(review)
    if review.user == user || user.admin?
      review.destroy
      { redirect_path: review.product, notice: "Review deleted successfully." }
    else
      { redirect_path: review.product, alert: "You are not authorized to delete this review." }
    end
  end

  def like_review(review)
    if review.user != user
      review.likes.create(user: user)
      { redirect_path: product_path(review.product), notice: "Liked the review!" }
    else
      { redirect_path: product_path(review.product), alert: "You can't like your own review." }
    end
  end

  def find_review(review_id)
    Review.find_by(id: review_id)
  end

  private

  def review_params
    params.require(:review).permit(:product_id, :rating, :content)
  end
end
