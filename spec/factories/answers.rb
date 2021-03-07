FactoryBot.define do
  factory :answer do
    user { nil }
    question { nil }
    body { "Answer's body" }

    trait :bodyless do
      body { nil }
    end

    trait :invalid do
      body { nil }
    end
  end
end
