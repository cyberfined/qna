RSpec.describe Reward, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional }
    it { should belong_to(:question) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }

    it 'should validate presense of picture' do
      reward = Reward.create
      expect(reward.errors).to be_added :picture, 'must be attached'
    end

    it 'should be valid type of an image' do
      reward = Reward.create
      reward.picture.attach(io: File.open(Rails.root.join('spec', 'miscs', 'reward.png')),
                            filename: 'reward.png')
      reward.validate

      expect(reward.errors).to_not be_added :picture, 'must be attached'
      expect(reward.errors).to_not be_added :picture, 'must be an image'
    end

    it 'should be invalid type of an image' do
      reward = Reward.create
      reward.picture.attach(io: File.open(Rails.root.join('public', '403.html')),
                            filename: '403.html')
      reward.validate

      expect(reward.errors).to_not be_added :picture, 'must be attached'
      expect(reward.errors).to be_added :picture, 'must be an image'
    end
  end

  describe 'active storage tests' do
    it 'have one attached picture' do
      expect(Reward.new.picture).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end

  describe 'give! method' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }
    let!(:reward) { create(:reward, question: question) }

    it 'should reward user' do
      reward.give!(user)
      expect(reward.user.id).to eq(user.id)
    end

    it 'should reward another_user' do
      another_user = create(:user)
      reward.give!(user)
      expect(reward.user.id).to eq(user.id)
      reward.give!(another_user)
      expect(reward.user.id).to eq(another_user.id)
    end
  end
end
