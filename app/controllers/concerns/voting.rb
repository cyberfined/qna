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
      if current_user.author_of?(@votable)
        render status: :forbidden, json: {
          message: "Author can't vote for his #{controller_name.classify.downcase}"
        }
      else
        vote_method.call(current_user)
        render json: {
          rating: @votable.rating
        }
      end
    end

    def find_votable
      @votable = controller_name.classify.constantize.find(params[:id])
    end
  end
end
