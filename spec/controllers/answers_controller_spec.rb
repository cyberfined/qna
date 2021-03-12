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
          post :create, params: { answer: attributes_for(:answer), question_id: question.id, format: :js }
          expect(response).to render_template :create
        end
      end

      context 'with invalid attributes' do
        it "doesn't create invalid answer" do
          expect {
            post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question.id, format: :js }
          }.to_not change { question.answers.count }
        end

        it 'renders create template' do
          post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question.id, format: :js }
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

  describe 'POST #update' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }

    context 'when user is authenticated' do
      let(:valid_answer) { build(:answer) }
      let(:invalid_answer) { build(:answer, :invalid) }

      before { sign_in(user) }

      context 'authorized actions' do
        let!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

        context 'with valid attributes' do
          before do
            post :update, params: { id: answer.id, answer: valid_answer.attributes, format: :js }
          end

          it 'updates answer' do
            answer.reload
            expect(answer.body).to eq(valid_answer.body)
          end

          it 'renders update template' do
            expect(response).to render_template :update
          end
        end

        context 'with invalid attributes' do
          before do
            post :update, params: { id: answer.id, answer: invalid_answer.attributes, format: :js }
          end

          it 'tries to update answer' do
            expect { answer.reload }.to_not change { answer }
          end

          it 'renders update template' do
            expect(response).to render_template :update
          end
        end
      end

      context 'unauthorized actions' do
        let!(:another_answer) { question.answers.create!(attributes_for(:answer, user: create(:user))) }

        before do
          post :update, params: { id: another_answer.id, answer: valid_answer.attributes, format: :js }
        end

        it "tries to update another user's answer" do
          expect { another_answer.reload }.to_not change { another_answer }
        end

        it 'returns an unauthorized error' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is unauthenticated' do
      let!(:answer) { question.answers.create!(attributes_for(:answer, user: create(:user))) }

      it "tries to update another user's answer" do
        post :update, params: { id: answer.id, answer: attributes_for(:answer), format: :js }
        expect { answer.reload }.to_not change { answer }
      end
    end
  end

  describe 'POST #mark_best' do
    context 'when user is authenticated' do
      let!(:user) { create(:user) }

      before { sign_in(user) }

      context 'authorized actions' do
        let!(:question) { user.questions.create!(attributes_for(:question)) }
        let!(:answers) { create_list(:answer, 2, question: question, user: user) }
        let(:another_question) { create(:question, user: user) }
        let(:another_answer) { another_question.answers.create!(attributes_for(:answer, user: user)) }

        it 'marks the best answer' do
          post :mark_best, params: { id: answers.first.id, format: :js }
          answers.each(&:reload)
          expect(answers.first.best).to be true
          expect(answers.second.best).to be false
        end

        it 'changes the best answer' do
          answers.first.update!(best: true)
          post :mark_best, params: { id: answers.second.id, format: :js }
          answers.each(&:reload)
          expect(answers.first.best).to be false
          expect(answers.second.best).to be true
        end

        it "tries to mark best answer that doesn't belong to the question" do
          answers.first.update!(best: true)
          post :mark_best, params: { id: another_answer.id, format: :js }
          answers.each(&:reload)
          expect(answers.first.best).to be true
          expect(answers.second.best).to be false
          expect(another_answer.best).to be false
        end

        it 'renders mark_best template' do
          post :mark_best, params: { id: another_answer.id, format: :js }
          expect(response).to render_template 'mark_best'
        end
      end

      context 'unauthorized actions' do
        let!(:another_user) { create(:user) }
        let!(:question) { another_user.questions.create!(attributes_for(:question)) }
        let!(:answer) { question.answers.create!(attributes_for(:answer, user: another_user)) }

        before do
          post :mark_best, params: { id: answer.id, format: :js }
        end

        it 'tries to mark the best answer' do
          answer.reload
          expect(answer.best).to be false
        end

        it 'returns an unauthorized error' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is unauthenticated' do
      let!(:user) { create(:user) }
      let!(:question) { user.questions.create!(attributes_for(:question)) }
      let!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

      it 'tries to mark the best answer' do
        post :mark_best, params: { id: answer.id, format: :js }
        answer.reload
        expect(answer.best).to be false
      end
    end
  end
end
