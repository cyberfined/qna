RSpec.describe DailyDigestService do
  let!(:users) { create_list(:user, 3) }

  it 'send daily digest to every user' do
    users.each do |user|
      expect(DailyDigestMailer).to receive(:digest_email).with(user).and_call_original
    end
    subject.send_digest
  end
end
