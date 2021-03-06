FactoryBot.define do
  factory :answer do
    body { "MyString" }
    question { nil }

    trait :bodyless do
      body { nil }
    end

    trait :invalid do
      body { nil }
    end
  end
end
