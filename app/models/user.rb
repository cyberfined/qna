class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :rewards
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  def author_of?(resource)
    self.id == resource.user_id
  end

  def subscription(question)
    subscriptions.find_by(question: question)
  end

  def subscribed?(question)
    subscription(question).present?
  end
end
