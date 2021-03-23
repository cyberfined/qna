module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, dependent: :destroy, as: :commentable

    def broadcast_channel
      self.class.broadcast_channel.call(self) unless self.class.broadcast_channel.nil?
    end
  end

  class_methods do
    attr_reader :broadcast_channel

    def set_broadcast_channel(get_channel)
      @broadcast_channel = get_channel
    end
  end
end
