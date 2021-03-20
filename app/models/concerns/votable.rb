module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, dependent: :destroy, as: :votable

    def vote_for!(user)
      vote_new_or_destroy!(user, :for)
    end

    def vote_against!(user)
      vote_new_or_destroy!(user, :against)
    end

    def rating
      votes.inject(0) { |sum,v| sum + Vote.votes[v.vote] }
    end

    private

    def vote_new_or_destroy!(user, vote_value)
      vote = votes.find_by(user: user)
      if vote.nil?
        votes.create!(vote: vote_value, user: user)
      elsif vote.vote != vote_value.to_s
        vote.destroy!
      end
    end
  end
end
