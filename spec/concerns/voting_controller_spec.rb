RSpec.shared_examples_for 'a voting controller' do
  describe 'POST #vote_for' do
    context 'when user is authenticated' do
      let!(:user) { create(:user) }

      before { sign_in(user) }

      it 'creates a new vote in the database' do
        expect {
          post :vote_for, params: { id: votable.id }
        }.to change { votable.votes.count }.by(1)
        expect(votable.rating).to eq(1)
      end

      it "doesn't create a new vote in the database" do
        votable.votes.create!(vote: Vote::FOR, user: user)
        expect {
          post :vote_for, params: { id: votable.id }
        }.to_not change { Vote.count }
        expect(votable.rating).to eq(1)
      end

      it 'removes a vote from the database' do
        votable.votes.create!(vote: Vote::AGAINST, user: user)
        expect {
          post :vote_for, params: { id: votable.id }
        }.to change { Vote.count }.by(-1)
        expect(votable.rating).to eq(0)
      end

      it 'renders a json with a new rating' do
        post :vote_for, params: { id: votable.id }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'when user is authenticated as an author of a votable' do
      before { sign_in(author) }

      it "doesn't create a new vote in the database" do
        expect {
          post :vote_for, params: { id: votable.id }
        }.to_not change { Vote.count }
        expect(votable.rating).to eq(0)
      end

      it 'returns an unauthorized error' do
        post :vote_for, params: { id: votable.id }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user is unauthenticated' do
      it "doesn't create a new vote in the database" do
        expect {
          post :vote_for, params: { id: votable.id }
        }.to_not change { Vote.count }
        expect(votable.rating).to eq(0)
      end
    end
  end

  describe 'POST #vote_against' do
    context 'when user is authenticated' do
      let!(:user) { create(:user) }

      before { sign_in(user) }

      it 'creates a new vote in the database' do
        expect {
          post :vote_against, params: { id: votable.id }
        }.to change { votable.votes.count }.by(1)
        expect(votable.rating).to eq(-1)
      end

      it "doesn't create a new vote in the database" do
        votable.votes.create!(vote: Vote::AGAINST, user: user)
        expect {
          post :vote_against, params: { id: votable.id }
        }.to_not change { Vote.count }
        expect(votable.rating).to eq(-1)
      end

      it 'removes a vote from the database' do
        votable.votes.create!(vote: Vote::FOR, user: user)
        expect {
          post :vote_against, params: { id: votable.id }
        }.to change { Vote.count }.by(-1)
        expect(votable.rating).to eq(0)
      end

      it 'renders a json with a new rating' do
        post :vote_against, params: { id: votable.id }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'when user is authenticated as an author of a votable' do
      before { sign_in(author) }

      it "doesn't create a new vote in the database" do
        expect {
          post :vote_against, params: { id: votable.id }
        }.to_not change { Vote.count }
        expect(votable.rating).to eq(0)
      end

      it 'returns an unauthorized error' do
        post :vote_against, params: { id: votable.id }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user is unauthenticated' do
      it "doesn't create a new vote in the database" do
        expect {
          post :vote_against, params: { id: votable.id }
        }.to_not change { Vote.count }
        expect(votable.rating).to eq(0)
      end
    end
  end
end

RSpec.describe QuestionsController, type: :controller do
  it_should_behave_like 'a voting controller' do
    let!(:author) { create(:user) }
    let!(:votable) { author.questions.create!(attributes_for(:question)) }
  end
end

RSpec.describe AnswersController, type: :controller do
  it_should_behave_like 'a voting controller' do
    let!(:author) { create(:user) }
    let!(:votable) do
      question = author.questions.create!(attributes_for(:question))
      question.answers.create!(attributes_for(:answer, user: author))
    end
  end
end
