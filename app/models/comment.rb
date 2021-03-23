class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :body, presence: true

  def as_json(options=nil)
    { id: id,
      commentable: { class: commentable.class.name, id: commentable.id },
      user: { id: user.id, email: user.email },
      body: body
    }
  end
end
