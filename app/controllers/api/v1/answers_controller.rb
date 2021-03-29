class Api::V1::AnswersController < Api::V1::BaseController
  load_and_authorize_resource

  def index
    render json: @answers
  end

  def show
    render json: @answer
  end

  def create
    @answer.user = current_user
    @answer.question = Question.find(params[:question_id])
    if @answer.save
      render json: @answer
    else
      render status: :unprocessable_entity, json: { errors: @answer.errors.full_messages }
    end
  end

  def update
    if @answer.update(answer_params)
      render json: @answer
    else
      render status: :unprocessable_entity, json: { errors: @answer.errors.full_messages }
    end
  end

  def destroy
    @answer.destroy
  end

  private

  def answer_params
    params.tap { |p| p[:links_attributes] = p[:links] }
          .require(:answer)
          .permit(:body, links_attributes: [:title, :url])
  end
end
