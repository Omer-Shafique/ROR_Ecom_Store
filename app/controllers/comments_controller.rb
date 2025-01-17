class CommentsController < ApplicationController
  before_action :find_review
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @review.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to product_path(@review.product), notice: 'Comment added!'
    else
      redirect_to product_path(@review.product), alert: 'Error adding comment!'
    end
  end

  def destroy
    if current_user == @comment.user || current_user.admin?
      @comment.destroy
      redirect_to product_path(@review.product), notice: 'Comment deleted successfully.'
    else
      redirect_to product_path(@review.product), alert: 'You do not have permission to delete this comment.'
    end
  end

  private

  def find_review
    @review = Review.find(params[:review_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
