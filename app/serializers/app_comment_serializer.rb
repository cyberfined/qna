class AppCommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :commentable
  belongs_to :user

  def commentable
    { id: object.commentable.id,
      class: object.commentable.class.name
    }
  end
end
