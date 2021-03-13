FactoryBot.define do
  sequence :answer_body do |n|
    "Answer #{n} body"
  end

  factory :answer do
    user { nil }
    question { nil }
    best { false }
    body { generate :answer_body }

    trait :bodyless do
      body { nil }
    end

    trait :invalid do
      body { nil }
    end
  end
end
