class Question < ApplicationRecord
  belongs_to :user
  has_many :answers, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true

  has_many_attached :files

  def best_answer
    answers.find_by(best: true)
  end
end
