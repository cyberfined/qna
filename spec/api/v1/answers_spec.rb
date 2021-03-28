RSpec.describe 'answers API', type: :request do
  let(:headers) {{ 'ACCEPT' => 'application/json' }}
  let(:auth_headers) { headers.merge('Authorization' => "Bearer #{access_token.token}",
                                     'CONTENT_TYPE' => 'application/json') }
  let!(:user) { create(:user) }
  let!(:question) { user.questions.create!(attributes_for(:question)) }
  let!(:access_token) { create(:access_token, resource_owner_id: user.id) }
  let(:json_fields) { %w[id body best rating created_at updated_at] }

  def answer_attachments(a)
    create_list(:comment, 3, commentable: a, user: user)
    a.links.create!([{ title: 'google', url: 'https://google.com' },
                     { title: 'yandex', url: 'https://ya.ru' }])
    a.files.attach(io: File.open(Rails.root.join('public', '403.html')), filename: '403.html')
    a.files.attach(io: File.open(Rails.root.join('public', '404.html')), filename: '404.html')
  end

  describe 'GET /api/v1/question/:question_id/answers' do
    let!(:answers) do
      answers = create_list(:answer, 3, question: question, user: user)
      answers.each { |answer| answer_attachments(answer) }
      answers
    end

    let(:api_path) { api_v1_question_answers_path(question) }
    let(:method) { :get }

    it_behaves_like 'API v1 authorizable'

    it_behaves_like 'API v1 showable' do
      let(:json_key) { 'answers' }
      let(:entities) { answers }
    end
  end

  describe 'GET /api/v1/answers/:id' do
    let!(:answer) do
      answer = question.answers.create!(attributes_for(:answer, user: user))
      answer_attachments(answer)
      answer
    end

    let(:api_path) { api_v1_answer_path(answer) }
    let(:method) { :get }

    it_behaves_like 'API v1 authorizable'

    it_behaves_like 'API v1 showable' do
      let(:json_key) { 'answer' }
      let(:entities) { [answer] }
    end
  end

  describe 'POST /api/v1/questions/:question_id/answers' do
    let(:api_path) { api_v1_question_answers_path(question) }
    let(:method) { :post }

    it_behaves_like 'API v1 authorizable'

    it_behaves_like 'API v1 creatable' do
      let(:entity) { build(:answer) }
      let(:invalid_entity) { build(:answer, :invalid) }
    end
  end

  describe 'PUT /api/v1/answers/:id' do
    let!(:answer) do
      answer = question.answers.create!(attributes_for(:answer, user: user))
      answer_attachments(answer)
      answer
    end
    let(:method) { :put }

    it_behaves_like 'API v1 authorizable' do
      let(:api_path) { api_v1_answer_path(answer) }
    end

    it_behaves_like 'API v1 updatable' do
      let(:entity) { answer }
      let!(:another_entity) { question.answers.create!(attributes_for(:answer, user: create(:user))) }
      let(:new_valid_entity) { build(:answer) }
      let(:new_invalid_entity) { build(:answer, :invalid) }
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    let!(:answer) do
      answer = question.answers.create!(attributes_for(:answer, user: user))
      answer_attachments(answer)
      answer
    end
    let(:method) { :delete }

    it_behaves_like 'API v1 authorizable' do
      let(:api_path) { api_v1_answer_path(answer) }
    end

    it_behaves_like 'API v1 deletable' do
      let(:entity) { answer }
      let!(:another_entity) { question.answers.create!(attributes_for(:answer, user: create(:user))) }
    end
  end
end
