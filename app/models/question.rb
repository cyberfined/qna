class Question < ApplicationRecord
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable

  validates :title, presence: true
  validates :body, presence: true

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank

  def best_answer
    answers.find_by(best: true)
  end
end
