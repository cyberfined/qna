RSpec.describe QuestionsController, type: :controller do
  describe 'POST #create' do
    context 'when user is authenticated' do
      before { sign_in create(:user) }

      context 'with valid attributes' do
        it 'creates new question in the database' do
          expect {
            post :create, params: { question: attributes_for(:question) }
          }.to change { Question.count }.by(1)
        end

        it 'redirects to show view' do
          post :create, params: { question: attributes_for(:question) }
          expect(response).to redirect_to controller.question
        end
      end

      context 'with invalid attributes' do
        it "doesn't create invalid question" do
          expect {
            post :create, params: { question: attributes_for(:question, :invalid) }
          }.not_to change { Question.count }
        end

        it 're-renders new view' do
          post :create, params: { question: attributes_for(:question, :invalid) }
          expect(response).to render_template :new
        end
      end
    end

    context 'when user is unauthenticated' do
      it 'tries to create new question in the database' do
        expect {
            post :create, params: { question: attributes_for(:question) }
        }.to_not change { Question.count }
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is authenticated' do
      let!(:user) { create(:user) }
      before { sign_in user }

      context 'authorized actions' do
        let!(:question) { user.questions.create!(attributes_for(:question)) }

        it 'deletes question from the database' do
          expect {
            delete :destroy, params: { id: question.id }
          }.to change { Question.count }.by(-1)
        end

        it 'redirects to questions' do
          delete :destroy, params: { id: question.id }
          expect(response).to redirect_to questions_path
        end
      end

      context 'unauthorized actions' do
        let!(:another_question) { create(:user).questions.create!(attributes_for(:question)) }

        it "tries to delete another user's question" do
          expect {
            delete :destroy, params: { id: another_question.id }
          }.to_not change { Question.count }
        end

        it 'returns an unauthorized error' do
          delete :destroy, params: { id: another_question.id }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when user is unauthenticated' do
      let!(:question) { create(:user).questions.create!(attributes_for(:question)) }

      it "tries to delete another user's question" do
        expect {
          delete :destroy, params: { id: question.id }
        }.to_not change { Question.count }
      end
    end
  end
end
