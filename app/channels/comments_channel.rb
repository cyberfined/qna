class CommentsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "comments_#{params[:id]}"
  end
end
