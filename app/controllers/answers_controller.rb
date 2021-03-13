class AnswersController < ApplicationController
  before_action :authenticate_user!, only: %i[create update destroy mark_best]

  expose :answer
  expose :question

  def create
    answer.user = current_user
    answer.question = question
    answer.save
  end

  def update
    if current_user.author_of?(answer)
      answer.update(answer_params)
    else
      render file: Rails.root.join(Rails.public_path, "403.html"), status: :forbidden
    end
  end

  def destroy
    if current_user.author_of?(answer)
      answer.destroy
    else
      render file: Rails.root.join(Rails.public_path, "403.html"), status: :forbidden
    end
  end

  def mark_best
    if current_user.author_of?(answer)
      answer.mark_best!
    else
      render file: Rails.root.join(Rails.public_path, "403.html"), status: :forbidden
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
