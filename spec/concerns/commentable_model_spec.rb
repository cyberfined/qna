RSpec.shared_examples_for 'a commentable model' do
  describe 'associations' do
    it { should have_many(:comments).dependent(:destroy) }
  end
end

RSpec.describe Question, type: :model do
  it_should_behave_like 'a commentable model'
end

RSpec.describe Answer, type: :model do
  it_should_behave_like 'a commentable model'
end
