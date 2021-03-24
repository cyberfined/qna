RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:questions).dependent(:destroy) }
    it { should have_many(:answers).dependent(:destroy) }
    it { should have_many(:rewards) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe 'author_of? method' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let(:question) { create(:question, user: user) }

    it 'should return true because user owns this question' do
      expect(user).to be_author_of question
    end

    it "should return false because user doesn't own this question" do
      expect(another_user).to_not be_author_of question
    end
  end
end
