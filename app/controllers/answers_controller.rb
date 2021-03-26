class AnswersController < ApplicationController
  include Voting

  before_action :authenticate_user!, only: %i[create update destroy mark_best vote_for vote_against]
  before_action :authorize_answer!, except: %i[vote_for vote_against]
  after_action :publish_answer, only: :create

  expose :answer, scope: -> { Answer.with_attached_files }
  expose :question

  def create
    answer.user = current_user
    answer.question = question
    answer.save
  end

  def update
    answer.update(answer_params)
  end

  def destroy
    answer.destroy
  end

  def mark_best
    answer.mark_best!
  end

  private

  def authorize_answer!
    authorize!(params[:action].to_sym, answer)
  end

  def answer_params
    params.require(:answer).permit(:body, files: [],
                                   links_attributes: [:id, :title, :url, :_destroy])
  end

  def publish_answer
    return unless answer.persisted?

    ActionCable.server.broadcast("answers_#{question.id}", answer)
  end
end
