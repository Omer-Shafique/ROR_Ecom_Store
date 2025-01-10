class CommentsService
  attr_reader :redirect_path

  def initialize(user, params)
    @user = user
    @params = params
    @redirect_path = nil
  end

  def create_comment
    comment = @user.comments.new(@params)
    if comment.save
      @redirect_path = comment.review.product
      true
    else
      @redirect_path = comment.review.product
      false
    end
  end
end
