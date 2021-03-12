class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :body, presence: true
  validate :validate_best_answers, if: :best

  scope :best_first, -> { order(best: :desc) }

  def mark_best!
    question.best_answer&.update!(best: false)
    update!(best: true)
  end

  private

  def validate_best_answers
    if question.present? && question.answers.where(best: true).count >= 1
      errors.add(:question, 'can have only one best answer')
    end
  end
end
