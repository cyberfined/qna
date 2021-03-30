class DailyDigestMailer < ApplicationMailer
  default from: 'notifications@qna.com'

  def digest_email(user)
    @questions = Question.where('created_at > ?', 1.days.ago)
    mail(to: user.email, subject: 'New questions digest')
  end
end
