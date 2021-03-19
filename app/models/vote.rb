class Vote < ApplicationRecord
  enum vote: { against: -1, for: 1 }

  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :user, uniqueness: { scope: :votable }
  validate :validate_author_cannot_vote

  private

  def validate_author_cannot_vote
    errors.add(:author, "can't vote for its own votable") if user&.author_of?(votable)
  end
end
