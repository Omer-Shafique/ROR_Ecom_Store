class CommentsController < ApplicationController
  include Authentication

  def create
    service = CommentsService.new(current_user, comment_params)
    if service.create_comment
      redirect_to service.redirect_path, notice: "Comment added successfully."
    else
      redirect_to service.redirect_path, alert: "Failed to add comment."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:review_id, :content)
  end
end










# class CommentsController < ApplicationController
#   before_action :authenticate_user!

#   def create
#     service = CommentsService.new(current_user, comment_params)
#     if service.create_comment
#       redirect_to service.redirect_path, notice: "Comment added successfully."
#     else
#       redirect_to service.redirect_path, alert: "Failed to add comment."
#     end
#   end

#   private

#   def comment_params
#     params.require(:comment).permit(:review_id, :content)
#   end
# end
