FactoryBot.define do
  factory :answer do
    body { "MyString" }
    question { nil }

    trait :invalid do
      body { nil }
    end
  end
end
