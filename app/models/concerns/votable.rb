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
      vote = Vote.find_by(votable: self, user: user)
      if vote.nil?
        Vote.create!(vote: vote_value, votable: self, user: user)
      elsif vote.vote != vote_value.to_s
        vote.destroy!
      end
    end
  end
end
