RSpec.describe DailyDigestMailer, type: :mailer do
  describe 'digest_email' do
    let(:user) { create(:user) }
    let(:mail) { DailyDigestMailer.digest_email(user) }
    let!(:new_questions) { create_list(:question, 3, user: user) }
    let!(:old_questions) { create_list(:question, 3, user:user, created_at: 2.days.ago) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'New questions digest'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['notifications@qna.com']
    end

    it 'renders new questions' do
      new_questions.each do |question|
        expect(mail.body).to have_link question.title, href: question_url(question)
      end
    end

    it "doesn't render old questions" do
      old_questions.each do |question|
        expect(mail.body).to have_no_link question.title
      end
    end
  end
end
