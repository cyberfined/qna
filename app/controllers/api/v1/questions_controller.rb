class Api::V1::QuestionsController < Api::V1::BaseController
  load_and_authorize_resource

  def index
    render json: @questions
  end

  def show
    render json: @question
  end

  def create
    @question.user = current_user
    if @question.save
      render json: @question
    else
      render status: :unprocessable_entity, json: { errors: @question.errors.full_messages }
    end
  end

  def update
    if @question.update(question_params)
      render json: @question
    else
      render status: :unprocessable_entity, json: { errors: @question.errors.full_messages }
    end
  end

  def destroy
    @question.destroy
    head :ok
  end

  private

  def question_params
    params.tap { |p| p[:links_attributes] = p[:links] }
          .require(:question)
          .permit(:title, :body, links_attributes: [:title, :url])
  end
end
