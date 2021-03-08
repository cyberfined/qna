FactoryBot.define do
  sequence :question_title do |n|
    "Question #{n} title"
  end

  sequence :question_body do |n|
    "Question #{n} body"
  end

  factory :question do
    user { nil }
    title { generate :question_title }
    body { generate :question_body }

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
