RSpec.describe AnswersController, type: :controller do
  describe 'POST #create' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }

    context 'when user is authenticated' do
      before { sign_in user }

      context 'with valid attributes' do
        it 'creates new answer in the database' do
          expect {
            post :create, params: { answer: attributes_for(:answer), question_id: question.id, format: :js }
          }.to change { question.answers.count }.by(1)
        end

        it 'renders create template' do
          post :create, params: { answer: attributes_for(:answer), question_id: question.id, format: :js}
          expect(response).to render_template :create
        end
      end

      context 'with invalid attributes' do
        it "doesn't create invalid answer" do
          expect {
            post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question.id, format: :js}
          }.to_not change { question.answers.count }
        end

        it 'renders create template' do
          post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question.id, format: :js}
          expect(response).to render_template :create
        end
      end
    end

    context 'when user is unauthenticated' do
      it 'tries to create new answer in the database' do
        expect {
          post :create, params: { answer: attributes_for(:answer), question_id: question.id }
        }.to_not change { question.answers.count }
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is authenticated' do
      let!(:user) { create(:user) }
      let!(:question) { user.questions.create!(attributes_for(:question)) }

      before { sign_in user }

      context 'authorized actions' do
        let!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

        it 'deletes answer from the database' do
          expect {
            delete :destroy, params: { id: answer.id, format: :js }
          }.to change { Answer.count }.by(-1)
        end

        it 'renders destroy template' do
          delete :destroy, params: { id: answer.id, format: :js }
          expect(response).to render_template 'destroy'
        end
      end

      context 'unauthorized actions' do
        let!(:another_user) { create(:user) }
        let!(:another_answer) { question.answers.create!(attributes_for(:answer, user: another_user)) }

        it "tries to delete another user's answer" do
          expect {
            delete :destroy, params: { id: another_answer.id, format: :js }
          }.to_not change { Answer.count }
        end

        it 'returns an unauthorized error' do
          delete :destroy, params: { id: another_answer.id, format: :js }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is unauthenticated' do
      let!(:user) { create(:user) }
      let!(:question) { user.questions.create!(attributes_for(:question)) }
      let!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

      it "tries to delete another user's question" do
        expect {
          delete :destroy, params: { id: answer.id }
        }.to_not change { Answer.count }
      end
    end
  end
end
