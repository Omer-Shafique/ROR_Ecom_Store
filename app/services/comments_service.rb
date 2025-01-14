class CommentsService
  attr_reader :user, :params, :comment, :redirect_path

  def initialize(user, params)
    @user = user
    @params = params
    @redirect_path = "/reviews/#{params[:review_id]}"  # Assuming review-based redirect
  end

  def create_comment
    @comment = Comment.new(user: user, review_id: params[:review_id], content: params[:content])

    if comment.save
      true
    else
      false
    end
  end
end
