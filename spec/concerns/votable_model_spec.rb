RSpec.shared_examples_for 'a votable model' do
  describe 'associations' do
    it { should have_many(:votes).dependent(:destroy) }
  end

  describe 'vote_for! method' do
    let!(:user) { create(:user) }

    it 'votes for at the first time' do
      expect { votable.vote_for!(user) }.to change { votable.votes.count }.by(1)
      expect(votable.rating).to eq(1)
    end

    it 'tries to vote for at the second time' do
      votable.vote_for!(user)
      expect { votable.vote_for!(user) }.to_not change { Vote.count }
      expect(votable.rating).to eq(1)
    end

    it 'votes for after voiting against' do
      votable.vote_against!(user)
      expect(votable.rating).to eq(-1)
      expect { votable.vote_for!(user) }.to change { Vote.count }.by(-1)
      expect(votable.reload.rating).to eq(0)
    end
  end

  describe 'vote_against! method' do
    let!(:user) { create(:user) }

    it 'votes against at the first time' do
      expect { votable.vote_against!(user) }.to change { votable.votes.count }.by(1)
      expect(votable.rating).to eq(-1)
    end

    it 'tries to vote against at the second time' do
      votable.vote_against!(user)
      expect { votable.vote_against!(user) }.to_not change { Vote.count }
    end

    it 'votes against after voiting for' do
      votable.vote_for!(user)
      expect(votable.rating).to eq(1)
      expect { votable.vote_against!(user) }.to change { Vote.count }.by(-1)
      expect(votable.reload.rating).to eq(0)
    end
  end

  describe 'rating method' do
    let!(:users) { create_list(:user, 2) }

    it 'should return 0 because of no votes' do
      expect(votable.rating).to eq(0)
    end

    it 'should return 0 because of sum of votes' do
      votable.votes.create!([ { vote: :for, user: users.first },
                              { vote: :against, user: users.second }])
      expect(votable.rating).to eq(0)
    end

    it 'should return 2 because of sum of votes' do
      votable.votes.create!([ { vote: :for, user: users.first },
                              { vote: :for, user: users.second }])
      expect(votable.rating).to eq(2)
    end

    it 'should return -2 because of sum of votes' do
      votable.votes.create!([ { vote: :against, user: users.first },
                              { vote: :against, user: users.second }])
      expect(votable.rating).to eq(-2)
    end
  end
end

RSpec.describe Question, type: :model do
  it_should_behave_like 'a votable model' do
    let!(:votable) { create(:user).questions.create!(attributes_for(:question)) }
  end
end

RSpec.describe Answer, type: :model do
  it_should_behave_like 'a votable model' do
    let!(:votable) do
      user = create(:user)
      question = user.questions.create!(attributes_for(:question))
      question.answers.create!(attributes_for(:answer, user: user))
    end
  end
end
