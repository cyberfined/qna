FactoryBot.define do
  factory :question do
    user { nil }
    title { "Question's title" }
    body { "Question's body" }

    trait :titleless do
      title { nil }
    end

    trait :bodyless do
      body { nil }
    end

    trait :invalid do
      title { nil }
    end
  end
end
