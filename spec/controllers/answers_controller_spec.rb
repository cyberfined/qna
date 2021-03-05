RSpec.describe AnswersController, type: :controller do
  describe 'POST #create' do
    let!(:question) { Question.create!(attributes_for(:question)) }

    context 'with valid attributes' do
      it 'creates new answer in the database' do
        expect {
          post :create, params: { answer: attributes_for(:answer), question_id: question.id }
        }.to change { question.answers.count }.by(1)
      end

      it 'redirects to show view' do
          post :create, params: { answer: attributes_for(:answer), question_id: question.id }
          expect(response).to redirect_to controller.answer
      end
    end

    context 'with invalid attributes' do
      it "doesn't create invalid answer" do
        expect {
          post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question.id }
        }.to_not change { Answer.count }
      end

      it 're-renders new view' do
        post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question.id }
        expect(response).to render_template :new
      end
    end
  end
end
