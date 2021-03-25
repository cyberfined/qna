module Voting
  extend ActiveSupport::Concern

  included do
    before_action :find_votable, only: %i[vote_for vote_against]

    def vote_for
      vote(@votable.method(:vote_for!))
    end

    def vote_against
      vote(@votable.method(:vote_against!))
    end

    private

    def vote(vote_method)
      authorize!(:vote, @votable)
      vote_method.call(current_user)
      render json: {
        rating: @votable.rating
      }
    end

    def find_votable
      @votable = controller_name.classify.constantize.find(params[:id])
    end
  end
end
