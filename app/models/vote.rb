class Vote < ApplicationRecord
  AGAINST = -1
  FOR = 1

  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :user, uniqueness: { scope: :votable }
  validates :vote, inclusion: { in: [AGAINST, FOR] }
  validate :validate_author_cannot_vote

  def for?
    vote == FOR
  end
  
  def against?
    vote == AGAINST
  end

  private

  def validate_author_cannot_vote
    errors.add(:author, "can't vote for its own votable") if user&.author_of?(votable)
  end
end
