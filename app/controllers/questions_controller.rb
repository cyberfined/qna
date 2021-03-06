class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  expose :questions, ->{ Question.all }
  expose :question
  expose :answer, ->{ Answer.new }

  def create
    if question.save
      redirect_to question, notice: 'You have succesfully create a question'
    else
      render :new
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
