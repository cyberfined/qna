RSpec.describe NewAnswerMailer, type: :mailer do
  describe 'new_answer_email' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }
    let!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }
    let(:mail) { NewAnswerMailer.new_answer_email(user, answer) }

    it 'renders the headers' do
      expect(mail.subject).to eq "New answer to the question #{question.title}"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['notifications@qna.com']
    end

    it 'renders a link to the question' do
      expect(mail.body).to have_link question.title, href: question_url(question)
    end

    it 'renders an answer' do
      expect(mail.body).to have_content answer.body
    end
  end
end
