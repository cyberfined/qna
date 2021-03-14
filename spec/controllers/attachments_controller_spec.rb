RSpec.describe AttachmentsController, type: :controller do
  describe 'DELETE #destroy' do
    context 'when user is authenticated' do
      let!(:user) { create(:user) }

      before { sign_in(user) }

      context 'authorized actions' do
        let!(:question) { user.questions.create!(attributes_for(:question)) }
        let!(:file) do
          question.files.attach(io: File.open(Rails.root.join(Rails.public_path, '403.html')),
                                filename: '403.html')
          question.files.first
        end

        it 'deletes an attached file' do
          expect {
            delete :destroy, params: { id: file.id, format: :js }
          }.to change { ActiveStorage::Attachment.count }.by(-1)
        end

        it 'renders destroy template' do
          delete :destroy, params: { id: file.id, format: :js }
          expect(response).to render_template :destroy
        end
      end

      context 'unauthorized actions' do
        let!(:another_user) { create(:user) }
        let!(:question) { another_user.questions.create!(attributes_for(:question)) }
        let!(:file) do
          question.files.attach(io: File.open(Rails.root.join(Rails.public_path, '403.html')),
                                filename: '403.html')
          question.files.first
        end

        it "tries to delete another user's attached file" do
          expect {
            delete :destroy, params: { id: file.id, format: :js }
          }.to_not change { ActiveStorage::Attachment.count }
        end

        it 'returns an unauthorized error' do
          delete :destroy, params: { id: file.id, format: :js }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is unauthenticated' do
      let!(:user) { create(:user) }
      let!(:question) { user.questions.create!(attributes_for(:question)) }
      let!(:file) do
        question.files.attach(io: File.open(Rails.root.join(Rails.public_path, '403.html')),
                              filename: '403.html')
        question.files.first
      end

      it "tries to delete another user's attached file" do
        expect {
          delete :destroy, params: { id: file.id, format: :js }
        }.to_not change { ActiveStorage::Attachment.count }
      end
    end
  end
end
