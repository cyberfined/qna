class CommentsController < ApplicationController
  ALLOWABLE_COMMENTABLE_CLASSES = %w(Question Answer).freeze

  before_action :authenticate_user!, only: :create
  before_action :authorize_comment!
  after_action :publish_comment, only: :create

  expose :comment

  def create
    comment.user = current_user
    comment.commentable = commentable
    comment.save
  end

  private

  def authorize_comment!
    authorize!(params[:action].to_sym, comment)
  end

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

  def publish_comment
    return unless comment.persisted?

    channel = comment.commentable.broadcast_channel
    if channel
      coder = SerializeEncoder.new(serializer: AppCommentSerializer)
      ActionCable.server.broadcast(channel, comment, coder: coder)
    end
  end
end
