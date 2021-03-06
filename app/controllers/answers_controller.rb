class AnswersController < ApplicationController
  before_action :authenticate_user!, only: :create

  expose :answer
  expose :question

  def create
    answer.question = question
    flash_params = if answer.save
                     { notice: 'You have successfully post an answer' }
                   else
                     { alert: flash_errors }
                   end
    redirect_to question, flash_params
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end

  def flash_errors
    answer.errors.map(&:full_message).join("\n")
  end
end
