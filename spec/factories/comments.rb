FactoryBot.define do
  sequence :comment_body do |n|
    "Comment #{n} body"
  end

  factory :comment do
    commentable { nil }
    user { nil }
    body { generate :comment_body }

    trait :invalid do
      body { nil }
    end
  end
end
