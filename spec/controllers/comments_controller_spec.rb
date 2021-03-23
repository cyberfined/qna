RSpec.describe CommentsController, type: :controller do
  describe 'POST #create' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }
    let(:comment) { attributes_for(:comment) }

    context 'when user is authenticated' do
      let(:invalid_comment) { attributes_for(:comment, :invalid) }

      before { sign_in(user) }

      context 'with valid attributes' do
        it 'creates a comment to the question' do
          expect {
            post :create, params: { commentable: { class: 'Question', id: question.id },
                                    comment: comment, format: :js }
          }.to change { question.comments.count }.by(1)
        end

        it 'creates a comment to the answer' do
          answer = question.answers.create!(attributes_for(:answer, user: user))
          expect {
            post :create, params: { commentable: { class: 'Answer', id: answer.id },
                                    comment: comment, format: :js }
          }.to change { answer.comments.count }.by(1)
        end

        it 'publish new comment to the comments channel' do
          post :create, params: { commentable: { class: 'Question', id: question.id },
                                  comment: comment, format: :js }
          assert_broadcast_on("comments_#{question.id}", Comment.first)
        end

        it 'renders create template' do
          post :create, params: { commentable: { class: 'Question', id: question.id },
                                  comment: comment, format: :js }
          expect(response).to render_template :create
        end
      end

      context 'with invalid attributes' do
        it 'tries to create a comment with an empty body' do
          expect {
            post :create, params: { commentable: { class: 'Question', id: question.id },
                                    comment: invalid_comment, format: :js }
          }.to_not change { Comment.count }
        end

        it 'tries to create a comment to an uncommentable entity' do
          expect {
            post :create, params: { commentable: { class: 'User', id: user.id },
                                    comment: comment, format: :js }
          }.to_not change { Comment.count }
        end

        it "doesn't broadcast to the comments channel" do
          post :create, params: { commentable: { class: 'Question', id: question.id },
                                  comment: invalid_comment, format: :js }
          assert_no_broadcasts("comments_#{question.id}")
        end

        it 'renders create template' do
          post :create, params: { commentable: { class: 'Question', id: question.id },
                                  comment: invalid_comment, format: :js }
          expect(response).to render_template :create
        end
      end
    end

    context 'when user is unauthenticated' do
      it 'tries to create a comment' do
        expect {
          post :create, params: { commentable: { class: 'Question', id: question.id },
                                  comment: comment, format: :js }
        }.to_not change { Comment.count }
      end
    end
  end
end
