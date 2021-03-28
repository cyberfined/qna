class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :rating, :created_at, :updated_at
  belongs_to :user
  has_many :links
  has_many :comments, serializer: ApiCommentSerializer
  has_many :files
end
