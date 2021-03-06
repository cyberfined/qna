FactoryBot.define do
  factory :question do
    title { "MyString" }
    body { "MyString" }

    trait :titleless do
      title { nil }
    end

    trait :bodyless do
      title { nil }
    end

    trait :invalid do
      title { nil }
    end
  end
end
