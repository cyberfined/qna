RSpec.describe NewAnswerService do
  let!(:question) { create(:user).questions.create!(attributes_for(:question)) }
  let!(:answer) { question.answers.create!(attributes_for(:answer, user: create(:user))) }
  let!(:subscribed_users) { create_list(:user, 3) }
  let!(:subscriptions) { subscribed_users.each { |u| Subscription.create!(user: u, question: question) }}

  before { subscribed_users.prepend(question.user) }

  it 'sends new answer notification to all subscribed users' do
    subscribed_users.each do |user|
      expect(NewAnswerMailer).to receive(:new_answer_email).with(user, answer).and_call_original
    end
    subject.send_notification(answer)
  end
end
