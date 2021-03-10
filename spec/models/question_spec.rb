RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:answers).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end
end
