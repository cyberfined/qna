class DailyDigestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    DailyDigestService.new.send_digest
  end
end
