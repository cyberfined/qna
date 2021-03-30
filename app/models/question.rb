class Question < ApplicationRecord
  include Votable
  include Commentable

  belongs_to :user
  has_one :reward, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_many :subscriptions, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :reward, reject_if: :all_blank

  after_create :add_author_subscription!

  set_broadcast_channel ->(q) { "comments_#{q.id}" }

  def best_answer
    answers.find_by(best: true)
  end

  private
  
  def add_author_subscription!
    subscriptions.create!(user: user)
  end
end
