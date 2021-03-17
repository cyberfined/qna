FactoryBot.define do
  sequence :reward_title do |n|
    "Reward #{n} title"
  end

  factory :reward do
    user { nil }
    question { nil }
    title { generate :reward_title }
    picture { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'miscs', 'reward.png'), 'image/png') }
  end
end
