class AnswersController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]

  expose :answer
  expose :question

  def create
    answer.user = current_user
    answer.question = question
    if answer.save
      redirect_to question, notice: 'You have successfully post an answer'
    else
      render 'questions/show'
    end
  end

  def destroy
    if current_user.author_of?(answer)
      answer.destroy
      redirect_to answer.question, notice: 'You successfully delete the answer'
    else
      render file: Rails.root.join(Rails.public_path, "401.html"), status: :unauthorized
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
