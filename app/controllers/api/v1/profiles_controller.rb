class Api::V1::ProfilesController < Api::V1::BaseController
  authorize_resource :user

  def index
    render json: User.where.not(id: current_user.id)
  end

  def me
    render json: current_user
  end
end
