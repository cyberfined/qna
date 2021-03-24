RSpec.describe Answer, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:question) }
    it { should have_many(:links).dependent(:destroy) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:question) { user.questions.create!(attributes_for(:question)) }

    it { should validate_presence_of(:body) }

    it 'should validate creation: only one answer can be the best' do
      expect {
        create_list(:answer, 2, question: question, user:user, best: true)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should validate updation: only one answer can be the best' do
      answers = create_list(:answer, 2, question: question, user: user)
      answers.first.update!(best: true)
      expect { answers.second.update!(best: true) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'broadcast_channel method' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }
    let!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

    it 'should return comments_#{answer.question.id}' do
      expect(answer.broadcast_channel).to eql("comments_#{question.id}")
    end
  end

  describe 'mark_best! method' do
    let!(:user) { create(:user) }

    context 'without reward' do
      let!(:question) { user.questions.create!(attributes_for(:question)) }
      let!(:answers) { create_list(:answer, 2, question: question, user: user) }

      it 'sets first answer as the best' do
        answers.first.mark_best!
        expect(answers.first).to be_best
        expect(answers.second).to_not be_best
      end

      it 'changes the best answer from first to the second one' do
        answers.first.mark_best!
        answers.each(&:reload)
        expect(answers.first).to be_best
        expect(answers.second).to_not be_best

        answers.second.mark_best!
        answers.each(&:reload)
        expect(answers.first).to_not be_best
        expect(answers.second).to be_best
      end
    end

    context 'with reward' do
      let!(:another_user) { create(:user) }
      let!(:question) { user.questions.create!(attributes_for(:question)) }
      let!(:reward) { create(:reward, question: question) }
      let!(:answers) {[ question.answers.create!(attributes_for(:answer, user: user)),
                        question.answers.create!(attributes_for(:answer, user: another_user)) ]}

      it 'sets first answer as the best' do
        answers.first.mark_best!
        expect(reward.reload.user.id).to eq(user.id)
        expect(answers.first).to be_best
        expect(answers.second).to_not be_best
      end

      it 'changes the best answer from first to the second one' do
        answers.first.mark_best!
        answers.each(&:reload)
        expect(reward.reload.user.id).to eq(user.id)
        expect(answers.first).to be_best
        expect(answers.second).to_not be_best

        answers.second.mark_best!
        answers.each(&:reload)
        expect(reward.reload.user.id).to eq(another_user.id)
        expect(answers.first).to_not be_best
        expect(answers.second).to be_best
      end
    end
  end

  describe 'active storage tests' do
    it 'have many attached files' do
      expect(Answer.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
    end
  end

  describe 'as_json method' do
    let!(:user) { create(:user) }
    let!(:question) { user.questions.create!(attributes_for(:question)) }

    it 'should return hash with empty files and links' do
      answer = question.answers.create!(attributes_for(:answer, user: user))

      answer_hash = answer.as_json
      expect(answer_hash[:id]).to eq(answer.id)
      expect(answer_hash[:body]).to eql(answer.body)
      expect(answer_hash[:user_id]).to eq(user.id)
      expect(answer_hash[:best]).to eq(answer.best)
      expect(answer_hash[:links]).to eq([])
      expect(answer_hash[:files]).to eq([])
    end
    
    it 'should return hash with links and empty files' do
      answer = question.answers.create!(attributes_for(:answer, user: user))
      link = answer.links.create!(title: 'example', url: 'https://example.com')

      answer_hash = answer.as_json
      expect(answer_hash[:id]).to eq(answer.id)
      expect(answer_hash[:body]).to eql(answer.body)
      expect(answer_hash[:user_id]).to eq(user.id)
      expect(answer_hash[:best]).to eq(answer.best)
      expect(answer_hash[:links]).to eq([link])
      expect(answer_hash[:files]).to eq([])
    end

    it 'should return hash with links and files' do
      answer = question.answers.create!(attributes_for(:answer, user: user))
      link = answer.links.create!(title: 'example', url: 'https://example.com')
      answer.files.attach(io: File.open(Rails.root.join('public', '404.html')), filename: '404.html')
      file_hash = [{ id: answer.files.first.id,
                     filename: answer.files.first.filename.to_s,
                     url: Rails.application.routes.url_helpers.rails_blob_path(answer.files.first, only_path: true) }]

      answer_hash = answer.as_json
      expect(answer_hash[:id]).to eq(answer.id)
      expect(answer_hash[:body]).to eql(answer.body)
      expect(answer_hash[:user_id]).to eq(user.id)
      expect(answer_hash[:best]).to eq(answer.best)
      expect(answer_hash[:links]).to eq([link])
      expect(answer_hash[:files]).to eql(file_hash)
    end
  end
end
