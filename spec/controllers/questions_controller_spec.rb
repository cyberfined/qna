RSpec.describe QuestionsController, type: :controller do
  include Devise::Test::ControllerHelpers

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
end
