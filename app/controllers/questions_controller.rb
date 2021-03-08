class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create destroy]

  expose :questions, ->{ Question.all }
  expose :question
  expose :answer, ->{ Answer.new }

  def create
    question.user = current_user
    if question.save
      redirect_to question, notice: 'You have succesfully create a question'
    else
      render :new
    end
  end

  def destroy
    if current_user.author_of?(question)
      question.destroy
      redirect_to :questions, notice: 'You successfully delete the question'
    else
      render file: Rails.root.join(Rails.public_path, "401.html"), status: :unauthorized
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
