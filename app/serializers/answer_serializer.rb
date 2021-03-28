class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :body, :best, :rating, :created_at, :updated_at
  belongs_to :user
  has_many :links
  has_many :comments, serializer: ApiCommentSerializer
  has_many :files
end
