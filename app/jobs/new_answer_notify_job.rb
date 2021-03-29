class NewAnswerNotifyJob < ApplicationJob
  queue_as :default

  def perform(answer)
    NewAnswerService.new.send_notification(answer)
  end
end
