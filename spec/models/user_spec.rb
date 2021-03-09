RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:questions).dependent(:destroy) }
    it { should have_many(:answers).dependent(:destroy) }
  end

  describe 'author_of? method' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let(:question) { create(:question, user: user) }
    let(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

    it 'should return true because user owns this question' do
      expect(user.author_of?(question)).to eq true
    end

    it 'should return true because user owns this answer' do
      expect(user.author_of?(answer)).to eq true
    end

    it "should return true because user doesn't own this question" do
      expect(another_user.author_of?(question)).to eq false
    end

    it "should return true because user doesn't own this answer" do
      expect(another_user.author_of?(answer)).to eq false
    end
  end
end
