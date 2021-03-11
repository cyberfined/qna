class AnswersController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]

  expose :answer
  expose :question

  def create
    answer.user = current_user
    answer.question = question
    answer.save
  end

  def destroy
    if current_user.author_of?(answer)
      answer.destroy
    else
      render file: Rails.root.join(Rails.public_path, "403.html"), status: :forbidden
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
