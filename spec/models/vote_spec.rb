RSpec.describe Vote, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:votable) }
    it { should define_enum_for(:vote) }
  end

  describe 'validations' do
    let!(:user) { create(:user) }

    context 'uniqueness of (user, votable)' do
      let!(:another_user) { create(:user) }

      it 'should return no errors' do
        question = another_user.questions.create!(attributes_for(:question))
        answer = question.answers.create!(attributes_for(:answer, user: another_user))
        expect {
          Vote.create!([{ user: user, votable: question, vote: :for },
                        { user: user, votable: answer, vote: :for }])
        }.to_not raise_error
      end

      it 'should return uniqueness validation error' do
        question = another_user.questions.create!(attributes_for(:question))
        expect {
          Vote.create!([{ user: user, votable: question, vote: :for },
                        { user: user, votable: question, vote: :against }])
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'author vote validation' do
      it "should return an error because author can't vote for its own votable" do
        question = user.questions.create!(attributes_for(:question))
        vote = Vote.new(user: user, votable: question, vote: :for)
        vote.validate
        expect(vote.errors).to be_added :author, "can't vote for its own votable"
      end

      it "shouldn't return an error because user can vote for another user's votable" do
        question = create(:user).questions.create!(attributes_for(:question))
        vote = Vote.new(user: user, votable: question, vote: :for)
        expect(vote).to be_valid
      end
    end
  end
end
