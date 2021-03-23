RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:commentable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'as_json method' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }
    let!(:comment) { question.comments.create!(attributes_for(:comment, user: user)) }

    it 'should return a valid hash' do
      comment_hash = comment.as_json
      expect(comment_hash[:id]).to eq(comment.id)
      expect(comment_hash[:body]).to eq(comment.body)
      expect(comment_hash[:commentable][:class]).to eql('Question')
      expect(comment_hash[:commentable][:id]).to eq(question.id)
      expect(comment_hash[:user][:id]).to eq(user.id)
      expect(comment_hash[:user][:email]).to eql(user.email)
    end
  end
end
