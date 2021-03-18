class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create update destroy]

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
    if current_user.author_of?(question)
      question.update(question_params)
    else
      render file: Rails.root.join(Rails.public_path, "403.html"), status: :forbidden
    end
  end

  def destroy
    if current_user.author_of?(question)
      question.destroy
      redirect_to :questions, notice: 'You successfully delete the question'
    else
      render file: Rails.root.join(Rails.public_path, "403.html"), status: :forbidden
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, files: [],
                                     links_attributes: [:id, :title, :url, :_destroy],
                                     reward_attributes: [:title, :picture])
  end
end
