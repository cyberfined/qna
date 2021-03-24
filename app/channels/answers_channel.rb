class AnswersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "answers_#{params[:id]}"
  end
end
