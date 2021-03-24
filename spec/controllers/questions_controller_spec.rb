RSpec.describe QuestionsController, type: :controller do
  include_context :gon

  describe 'GET #show' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }

    context 'when user is authenticated' do
      before { sign_in user }

      it 'should set gon.question_id and gon.user_id' do
        get :show, params: { id: question.id }
        expect(gon['question']).to eql({ id: question.id, user_id: user.id })
        expect(gon['user_id']).to eq user.id
      end
    end

    context 'when user is unauthenticated' do
      it 'should set gon.question_id and gon.user_id' do
        get :show, params: { id: question.id }
        expect(gon['question']).to eql({ id: question.id, user_id: user.id })
        expect(gon['user_id']).to eq nil
      end
    end
  end

  describe 'POST #create' do
    context 'when user is authenticated' do
      before { sign_in create(:user) }

      context 'with valid attributes' do
        it 'creates new question in the database' do
          expect {
            post :create, params: { question: attributes_for(:question) }
          }.to change { Question.count }.by(1)
        end

        it 'publish new question to the questions channel' do
          post :create, params: { question: attributes_for(:question) }
          question = Question.first
          assert_broadcast_on('questions', { id: question.id, title: question.title })
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

        it "doesn't broadcast to the questions channel" do
          post :create, params: { question: attributes_for(:question, :invalid) }
          assert_no_broadcasts('questions')
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

      it "doesn't broadcast to the questions channel" do
        post :create, params: { question: attributes_for(:question, :invalid) }
        assert_no_broadcasts('questions')
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
          expect(response).to have_http_status(:forbidden)
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

  describe 'POST #update' do
    context 'when user is authenticated' do
      let!(:user) { create(:user) }
      let(:valid_question) { build(:question) }
      let(:invalid_question) { build(:question, :invalid) }

      before { sign_in user }

      context 'authorized actions' do
        let!(:question) { user.questions.create!(attributes_for(:question)) }

        context 'with valid attributes' do
          before do
            post :update, params: { id: question.id, question: valid_question.attributes, format: :js }
          end

          it 'updates question' do
            question.reload
            expect(question.title).to eq(valid_question.title)
            expect(question.body).to eq(valid_question.body)
          end

          it 'renders update template' do
            expect(response).to render_template :update
          end
        end

        context 'with invalid attributes' do
          before do
            post :update, params: { id: question.id, question: invalid_question.attributes, format: :js }
          end

          it 'tries to update question' do
            expect { question.reload }.to_not change { question }
          end

          it 'renders update template' do
            expect(response).to render_template :update
          end
        end
      end

      context 'unauthorized actions' do
        let!(:another_question) { create(:user).questions.create!(attributes_for(:question)) }

        before do
          post :update, params: { id: another_question.id, question: valid_question.attributes, format: :js}
        end

        it 'tries to update question' do
          expect { another_question.reload }.to_not change { another_question }
        end

        it 'returns an unauthorized error' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is unauthenticated' do
      let!(:question) { create(:user).questions.create!(attributes_for(:question)) }

      it "tries to edit another user's question" do
        post :update, params: { id: question.id, question: attributes_for(:question), format: :js }
        expect { question.reload }.to_not change { question }
      end
    end
  end 
end
