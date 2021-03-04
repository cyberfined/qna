class AnswersController < ApplicationController
  expose :answer
  expose :question

  def create
    answer.question = question
    if answer.save
      redirect_to answer
    else
      render :new
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
