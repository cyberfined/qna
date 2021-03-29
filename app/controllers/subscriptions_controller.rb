class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]
  before_action :authorize_subscription!

  expose :subscription
  expose :question

  def create
    subscription.user = current_user
    subscription.question = question
    subscription.save
  end

  def destroy
    subscription.destroy
  end

  private

  def authorize_subscription!
    authorize!(params[:action].to_sym, subscription)
  end
end
