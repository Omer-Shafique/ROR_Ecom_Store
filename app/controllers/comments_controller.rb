class CommentsController < ApplicationController
  before_action :find_review
  before_action :set_comment, only: [:destroy]


  def show
    @product = Product.find(params[:id])
    @review = Review.find_by(product_id: @product.id) 
    @comment = Comment.new
  end

  
  def create
    @review = Review.find(params[:review_id])
    @comment = @review.comments.build(comment_params)
    @comment.user = current_user
  
    if @comment.save
      respond_to do |format|
        format.js 
        format.html { redirect_to @review.product }
      end
    else
      respond_to do |format|
        format.js { render :error }
        format.html { redirect_to @review.product, alert: "Unable to add comment." }
      end
    end
  end
  
  

  def destroy
    @review = Review.find(params[:review_id])
    @comment = @review.comments.find(params[:id])
    @comment.destroy
  
    respond_to do |format|
      format.html { redirect_to @review, notice: 'Comment was successfully deleted.' }
      format.js   # This will render a `destroy.js.erb` file
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
