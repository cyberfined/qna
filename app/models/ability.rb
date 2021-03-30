# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all
    return if user.nil?

    can :create, [Question, Answer, Comment, Subscription]
    can [:update, :destroy], [Question, Answer, Comment], user_id: user.id
    can :destroy, Subscription, user_id: user.id
    can :mark_best, Answer do |a|
      user.author_of?(a.question)
    end
    can :vote, [Question, Answer] do |v|
      !user.author_of?(v)
    end
    can :destroy, ActiveStorage::Attachment do |a|
      user.author_of?(a.record)
    end
  end
end
