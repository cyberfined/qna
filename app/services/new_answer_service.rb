class NewAnswerService
  def send_notification(answer)
    answer.question.subscriptions.each do |sub|
      NewAnswerMailer.new_answer_email(sub.user, answer).deliver_later
    end
  end
end
