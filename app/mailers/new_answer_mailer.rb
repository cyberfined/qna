class NewAnswerMailer < ApplicationMailer
  default from: 'notifications@qna.com'

  def new_answer_email(user, answer)
    @question = answer.question
    @answer = answer
    mail(to: user.email, subject: "New answer to the question #{@question.title}")
  end
end
