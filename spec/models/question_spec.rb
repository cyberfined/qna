RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:answers).dependent(:destroy) }
    it { should have_many(:links).dependent(:destroy) }
    it { should have_one(:reward).dependent(:destroy) }
    it { should have_many(:subscriptions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  describe 'subscription creation' do
    let!(:user) { create(:user) }

    it 'should create subscription' do
      expect {
        user.questions.create!(attributes_for(:question))
      }.to change { Subscription.count }.by(1)
    end

    it 'should create subscription for author and question' do
      question = user.questions.create!(attributes_for(:question))
      expect(question.subscriptions.first.user).to eq(user)
    end
  end

  describe 'best_answer method' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }
    let!(:answers) { create_list(:answer, 2, question: question, user: user) }

    it 'should return nil because of the best answer absence' do
      expect(question.best_answer).to be_nil
    end

    it 'should return the first answer' do
      answers.first.update!(best: true)
      expect(question.best_answer.id).to eq(answers.first.id)
    end
  end

  describe 'broadcast_channel method' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }

    it 'should return comments_#{question.id}' do
      expect(question.broadcast_channel).to eql("comments_#{question.id}")
    end
  end

  describe 'active storage tests' do
    it 'have many attached files' do
      expect(Question.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
    end
  end
end
