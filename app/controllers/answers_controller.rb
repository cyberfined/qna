class AnswersController < ApplicationController
  include Voting

  before_action :authenticate_user!, only: %i[create update destroy mark_best vote_for vote_against]

  expose :answer, scope: -> { Answer.with_attached_files }
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
    if current_user.author_of?(answer.question)
      answer.mark_best!
    else
      render file: Rails.root.join(Rails.public_path, "403.html"), status: :forbidden
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body, files: [],
                                   links_attributes: [:id, :title, :url, :_destroy])
  end
end
