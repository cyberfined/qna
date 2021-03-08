class AnswersController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]

  expose :answer
  expose :question

  def create
    answer.user = current_user
    answer.question = question
    flash_params = if answer.save
                     { notice: 'You have successfully post an answer' }
                   else
                     { alert: flash_errors }
                   end
    redirect_to question, flash_params
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

  def flash_errors
    answer.errors.map(&:full_message).join("\n")
  end
end
