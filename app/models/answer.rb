class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_many :links, dependent: :destroy, as: :linkable

  validates :body, presence: true
  validate :validate_best_answers, if: :best

  scope :best_first, -> { order(best: :desc) }

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank

  def mark_best!
    Answer.transaction do
      question.best_answer&.update!(best: false)
      update!(best: true)
    end
  end

  private

  def validate_best_answers
    if question.present? && question.answers.where(best: true).count >= 1
      errors.add(:question, 'can have only one best answer')
    end
  end
end
