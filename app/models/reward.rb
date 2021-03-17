class Reward < ApplicationRecord
  belongs_to :question
  belongs_to :user, optional: true

  validates :title, presence: true
  validate :validate_picture

  has_one_attached :picture

  def give!(user)
    update!(user: user)
  end

  private

  def validate_picture
    errors.add(:picture, 'must be attached') unless picture.attached?
    errors.add(:picture, 'must be an image') unless picture.image?
  end
end
