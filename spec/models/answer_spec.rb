RSpec.describe Answer, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:question) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:question) { user.questions.create!(attributes_for(:question)) }

    it { should validate_presence_of(:body) }

    it 'should validate creation: only one answer can be the best' do
      expect {
        create_list(:answer, 2, question: question, user:user, best: true)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should validate updation: only one answer can be the best' do
      answers = create_list(:answer, 2, question: question, user: user)
      answers.first.update!(best: true)
      expect { answers.second.update!(best: true) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'mark_best! method' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }
    let!(:answers) { create_list(:answer, 2, question: question, user: user) }

    it 'sets first answer as the best' do
      answers.first.mark_best!
      expect(answers.first).to be_best
      expect(answers.second).to_not be_best
    end

    it 'changes the best answer from first to the second one' do
      answers.first.update!(best: true)
      answers.second.mark_best!
      answers.each(&:reload)
      expect(answers.first).to_not be_best
      expect(answers.second).to be_best
    end
  end
end
