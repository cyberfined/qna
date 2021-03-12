RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:answers).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
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
end
