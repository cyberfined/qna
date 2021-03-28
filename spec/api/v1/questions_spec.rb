RSpec.describe 'questions API', type: :request do
  let(:headers) {{ 'ACCEPT' => 'application/json' }}
  let(:auth_headers) { headers.merge('Authorization' => "Bearer #{access_token.token}",
                                     'CONTENT_TYPE' => 'application/json') }
  let!(:user) { create(:user) }
  let!(:access_token) { create(:access_token, resource_owner_id: user.id) }
  let(:json_fields) { %w[id title body rating created_at updated_at] }

  def question_associations(q)
    create_list(:comment, 3, commentable: q, user: user)
    q.links.create!([{ title: 'google', url: 'https://google.com' },
                     { title: 'yandex', url: 'https://ya.ru' }])
    q.files.attach(io: File.open(Rails.root.join('public', '403.html')), filename: '403.html')
    q.files.attach(io: File.open(Rails.root.join('public', '404.html')), filename: '404.html')
  end

  describe 'GET /api/v1/questions' do
    let!(:questions) do
      questions = create_list(:question, 3, user: user)
      questions.each { |q| question_associations(q) }
      questions
    end

    let(:api_path) { api_v1_questions_path }
    let(:method) { :get }

    it_behaves_like 'API v1 authorizable'

    it_behaves_like 'API v1 showable' do
      let(:json_key) { 'questions' }
      let(:entities) { questions }
    end
  end

  describe 'GET /api/v1/questions/:id' do
    let!(:question) do
      question = user.questions.create!(attributes_for(:question))
      question_associations(question)
      question
    end

    let(:api_path) { api_v1_question_path(question) }
    let(:method) { :get }

    it_behaves_like 'API v1 authorizable'

    it_behaves_like 'API v1 showable' do
      let(:json_key) { 'question' }
      let(:entities) { [question] }
    end
  end

  describe 'POST /api/v1/questions' do
    let(:api_path) { api_v1_questions_path }
    let(:method) { :post }

    it_behaves_like 'API v1 authorizable'

    it_behaves_like 'API v1 creatable' do
      let(:entity) { build(:question) }
      let(:invalid_entity) { build(:question, :invalid) }
    end
  end

  describe 'PUT /api/v1/questions/:id' do
    let!(:question) do
      question = user.questions.create!(attributes_for(:question))
      question_associations(question)
      question
    end
    let(:method) { :put }

    it_behaves_like 'API v1 authorizable' do
      let(:api_path) { api_v1_question_path(question) }
    end

    it_behaves_like 'API v1 updatable' do
      let(:entity) { question }
      let!(:another_entity) { create(:user).questions.create!(attributes_for(:question)) }
      let(:new_valid_entity) { build(:question) }
      let(:new_invalid_entity) { build(:question, :invalid) }
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let!(:question) do
      question = user.questions.create!(attributes_for(:question))
      question_associations(question)
      question
    end
    let(:method) { :delete }

    it_behaves_like 'API v1 authorizable' do
      let(:api_path) { api_v1_question_path(question) }
    end

    it_behaves_like 'API v1 deletable' do
      let(:entity) { question }
      let!(:another_entity) { create(:user).questions.create!(attributes_for(:question)) }
    end
  end
end
