RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:commentable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end
end
