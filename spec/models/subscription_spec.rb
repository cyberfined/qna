RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:question) }
  end

  describe 'uniqueness of (user, question)' do
    let!(:user) { create(:user) }
    let!(:question) { create(:user).questions.create!(attributes_for(:question)) }

    it 'should return no errors' do
      expect {
        Subscription.create!(user: user, question: question)
      }.to_not raise_error
    end

    it 'should return uniqueness validation error' do
      Subscription.create!(user: user, question: question)
      expect {
        Subscription.create!(user: user, question: question)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
