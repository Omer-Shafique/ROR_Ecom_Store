class ReviewsService

  include ReviewAuthorization
  def initialize(user, params = nil)
    @user = user
    @params = params
  end

  def get_all_reviews
    Review.all
  end

  def create_review(product)
    review = product.reviews.build(@params[:review])
    review.user = @user
    review.save
    review
  end

  def delete_review(review)
    if @user == review.user || @user.admin?
      review.destroy
    else
      raise "Unauthorized"
    end
  end
  

  def like_review(review)
    like = review.likes.new(user: @user)
    if like.save
      { success: true, message: "You liked this review." }
    else
      { success: false, message: "You can only like a review once." }
    end
  end

  def find_review(review_id)
    Review.find_by(id: review_id)
  end
end
