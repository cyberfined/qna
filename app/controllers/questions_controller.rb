class QuestionsController < ApplicationController
  include Voting

  before_action :authenticate_user!, only: %i[new create update destroy vote_for vote_against]
  before_action :authorize_question!, except: %i[vote_for vote_against]
  before_action :set_gon_variables, only: :show
  after_action :publish_question, only: :create

  expose :questions, ->{ Question.all }
  expose :question, scope: -> { Question.with_attached_files }
  expose :answer, ->{ Answer.new }

  def create
    question.user = current_user
    if question.save
      redirect_to question, notice: 'You have succesfully create a question'
    else
      render :new
    end
  end

  def update
    question.update(question_params)
  end

  def destroy
    question.destroy
    redirect_to :questions, notice: 'You successfully delete the question'
  end

  private

  def authorize_question!
    authorize!(params[:action].to_sym, question)
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [],
                                     links_attributes: [:id, :title, :url, :_destroy],
                                     reward_attributes: [:title, :picture])
  end

  def publish_question
    return unless question.persisted?

    ActionCable.server.broadcast('questions', { id: question.id, title: question.title })
  end

  def set_gon_variables
    gon.question = {
      id: question.id,
      user_id: question.user.id
    }
    gon.user_id = current_user&.id
  end
end
