RSpec.describe NewAnswerNotifyJob, type: :job do
  let(:service) { double('NewAnswerService') }
  let(:question) { create(:user).questions.create!(attributes_for(:question)) }
  let(:answer) { question.answers.create!(attributes_for(:answer, user: create(:user))) }

  before { allow(NewAnswerService).to receive(:new).and_return(service) }

  it 'calls NewAnswerService#send_notification' do
    expect(service).to receive(:send_notification)
    NewAnswerNotifyJob.perform_now(answer)
  end
end
