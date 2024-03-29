class RewardsController < ApplicationController
  before_action :authenticate_user!, only: :index
  
  expose :rewards, -> { current_user.rewards }

  def index
    authorize!(:index, rewards)
  end
end
