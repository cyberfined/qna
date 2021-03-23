class CommentsController < ApplicationController
  ALLOWABLE_COMMENTABLE_CLASSES = %w(Question Answer).freeze

  before_action :authenticate_user!, only: :create

  expose :comment

  def create
    comment.user = current_user
    comment.commentable = commentable
    comment.save
  end

  private

  def commentable
    params = commentable_params
    return unless ALLOWABLE_COMMENTABLE_CLASSES.include?(params[:class])

    params[:class].constantize.find_by(id: params[:id])
  end

  def commentable_params
    params.require(:commentable).permit(:class, :id)
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
