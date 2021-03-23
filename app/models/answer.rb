class Answer < ApplicationRecord
  include Votable

  belongs_to :user
  belongs_to :question
  has_many :links, dependent: :destroy, as: :linkable

  validates :body, presence: true
  validate :validate_best_answers, if: :best

  scope :best_first, -> { order(best: :desc) }

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

  def mark_best!
    Answer.transaction do
      question.best_answer&.update!(best: false)
      update!(best: true)
      question.reward&.give!(user)
    end
  end

  def as_json(options=nil)
    files_array = files.map do |f|
      { id: f.id,
        filename: f.filename.to_s,
        url: Rails.application.routes.url_helpers.rails_blob_path(f, only_path: true)
      }
    end

    { id: id,
      body: body,
      user_id: user_id,
      best: best,
      links: links,
      files: files_array
    }
  end

  private

  def validate_best_answers
    if question.present? && question.answers.where(best: true).count >= 1
      errors.add(:question, 'can have only one best answer')
    end
  end
end
