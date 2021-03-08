FactoryBot.define do
  sequence :user_email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email { generate :user_email }
    password { "password" }

    trait :invalid_email do
      email { "wrongemail" }
    end

    trait :short_password do
      password { "12345" }
    end
  end
end
