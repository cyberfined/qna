require "cancan/matchers"

RSpec.describe Ability, type: :model do
  subject(:ability) { Ability.new(user) }

  describe 'for guest' do
    let(:user) { nil }

    it { should be_able_to :read, :all }

    it { should_not be_able_to :create, Question }
    it { should_not be_able_to :update, Question }
    it { should_not be_able_to :destroy, Question }
    it { should_not be_able_to :vote, Question }

    it { should_not be_able_to :create, Answer }
    it { should_not be_able_to :update, Answer }
    it { should_not be_able_to :destroy, Answer }
    it { should_not be_able_to :mark_best, Answer }
    it { should_not be_able_to :vote, Answer }

    it { should_not be_able_to :create, Comment }
    it { should_not be_able_to :update, Comment }
    it { should_not be_able_to :destroy, Comment }

    it { should_not be_able_to :create, Subscription }
    it { should_not be_able_to :destroy, Subscription }

    it { should_not be_able_to :destroy, ActiveStorage::Attachment }
  end

  describe 'for user' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }

    let(:question) { user.questions.create(attributes_for(:question)) }
    let(:another_question) { another_user.questions.create(attributes_for(:question)) }

    let(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }
    let(:another_answer) { another_question.answers.create!(attributes_for(:answer, user: another_user)) }

    let(:comment) { question.comments.create!(attributes_for(:comment, user: user)) }
    let(:another_comment) { question.comments.create!(attributes_for(:comment, user: another_user)) }

    let(:subscription) { Subscription.create!(user: user, question: another_question) }
    let(:another_subscription) { Subscription.create!(user: another_user, question: question) }

    let(:attachment) do
      question.files.attach(io: File.open(Rails.root.join('public', '404.html')), 
                            filename: '404.html')
      question.files.first
    end

    let(:another_attachment) do
      another_question.files.attach(io: File.open(Rails.root.join('public', '404.html')),
                                    filename: '404.html')
      another_question.files.first
    end

    it { should be_able_to :read, :all }

    it { should be_able_to :create, Question }
    it { should be_able_to :update, question }
    it { should be_able_to :destroy, question }
    it { should be_able_to :vote, another_question }
    it { should_not be_able_to :update, another_question }
    it { should_not be_able_to :destroy, another_question }
    it { should_not be_able_to :vote, question }

    it { should be_able_to :create, Answer }
    it { should be_able_to :update, answer }
    it { should be_able_to :destroy, answer }
    it { should be_able_to :mark_best, answer }
    it { should be_able_to :vote, another_answer }
    it { should_not be_able_to :update, another_answer }
    it { should_not be_able_to :destroy, another_answer }
    it { should_not be_able_to :mark_best, another_answer }
    it { should_not be_able_to :vote, answer }

    it { should be_able_to :create, Comment }
    it { should be_able_to :update, comment }
    it { should be_able_to :destroy, comment }
    it { should_not be_able_to :update, another_comment }
    it { should_not be_able_to :destroy, another_comment }

    it { should be_able_to :create, Subscription }
    it { should be_able_to :destroy, subscription }
    it { should_not be_able_to :destroy, another_subscription }

    it { should be_able_to :destroy, attachment }
    it { should_not be_able_to :destroy, another_attachment }
  end
end
