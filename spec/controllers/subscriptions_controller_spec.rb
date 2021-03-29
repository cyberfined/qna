RSpec.describe SubscriptionsController, type: :controller do
  describe 'POST #create' do
    let!(:question) { create(:user).questions.create!(attributes_for(:question)) }

    context 'when user is authenticated' do
      let!(:user) { create(:user) }

      before { sign_in(user) }

      it 'creates a subscription' do
        expect {
          post :create, params: { question_id: question.id, format: :js }
        }.to change { user.subscriptions.count }.by(1)
      end

      it 'tries to create a duplicate subscription' do
        Subscription.create!(user: user, question: question)
        expect {
          post :create, params: { question_id: question.id, format: :js }
        }.to_not change { Subscription.count }
      end

      it 'renders create template' do
        post :create, params: { question_id: question.id, format: :js }
        expect(response).to render_template :create
      end
    end

    context 'when user is unauthenticated' do
      it 'tries to create a subscription' do
        expect {
          post :create, params: { question_id: question.id, format: :js }
        }.to_not change { Subscription.count }
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }
    let!(:question) { create(:user).questions.create!(attributes_for(:question)) }
    let!(:subscription) { Subscription.create!(user: user, question: question) }

    context 'when user is authenticated' do

      before { sign_in(user) }

      context 'authorized actions' do
        it 'deletes a subscription' do
          expect {
            delete :destroy, params: { id: subscription.id, format: :js }
          }.to change { Subscription.count }.by(-1)
        end

        it 'renders destroy template' do
          delete :destroy, params: { id: subscription.id, format: :js }
          expect(response).to render_template :destroy
        end
      end

      context 'unauthorized actions' do
        let!(:another_subscription) { Subscription.create!(user: create(:user), question: question) }

        it "tries to delete another user's subscription" do
          expect {
            delete :destroy, params: { id: another_subscription.id, format: :js }
          }.to_not change { Subscription.count }
        end

        it 'returns an unauthorized error' do
          delete :destroy, params: { id: another_subscription.id, format: :js }
          expect(response).to have_http_status :forbidden
        end
      end
    end

    context 'when user is unauthenticated' do
      it 'tries to delete a subscription' do
        expect {
          delete :destroy, params: { id: subscription.id, format: :js }
        }.to_not change { Subscription.count }
      end
    end
  end
end
