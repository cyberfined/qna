RSpec.describe Vote, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:votable) }
  end

  describe 'validations' do
    it { should validate_inclusion_of(:vote).in_array([Vote::AGAINST, Vote::FOR]) }

    context 'uniqueness of (user, votable)' do
      let!(:user) { create(:user) }
      let!(:another_user) { create(:user) }

      it 'should return no errors' do
        question = another_user.questions.create!(attributes_for(:question))
        answer = question.answers.create!(attributes_for(:answer, user: another_user))
        expect {
          Vote.create!([{ user: user, votable: question, vote: Vote::FOR },
                        { user: user, votable: answer, vote: Vote::AGAINST }])
        }.to_not raise_error
      end

      it 'should return uniqueness validation error' do
        question = another_user.questions.create!(attributes_for(:question))
        expect {
          Vote.create!([{ user: user, votable: question, vote: Vote::FOR },
                        { user: user, votable: question, vote: Vote::AGAINST }])
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'author vote validation' do
      let!(:user) { create(:user) }

      it "should return an error because author can't vote for its own votable" do
        question = user.questions.create!(attributes_for(:question))
        vote = question.votes.new(user: user, vote: Vote::FOR)
        vote.validate
        expect(vote.errors).to be_added :author, "can't vote for its own votable"
      end

      it "shouldn't return an error because user can vote for another user's votable" do
        question = create(:user).questions.create!(attributes_for(:question))
        vote = question.votes.new(user: user, vote: Vote::FOR)
        expect(vote).to be_valid
      end
    end
  end

  describe 'for? method' do
    let!(:user) { create(:user) }
    let!(:question) { create(:user).questions.create!(attributes_for(:question)) }

    it 'should return true' do
      vote = question.votes.create!(vote: Vote::FOR, user: user)
      expect(vote).to be_for
    end

    it 'should return false' do
      vote = question.votes.create!(vote: Vote::AGAINST, user: user)
      expect(vote).to_not be_for
    end
  end

  describe 'against? method' do
    let!(:user) { create(:user) }
    let!(:question) { create(:user).questions.create!(attributes_for(:question)) }

    it 'should return true' do
      vote = question.votes.create!(vote: Vote::AGAINST, user: user)
      expect(vote).to be_against
    end

    it 'should return false' do
      vote = question.votes.create!(vote: Vote::FOR, user: user)
      expect(vote).to_not be_against
    end
  end
end
