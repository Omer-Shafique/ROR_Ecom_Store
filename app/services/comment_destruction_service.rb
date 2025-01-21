class CommentDestructionService
  def initialize(review, comment_id)
    @review = review
    @comment_id = comment_id
  end

  def call
    comment = @review.comments.find(@comment_id)
    comment.destroy
  end
end