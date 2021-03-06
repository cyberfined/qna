FactoryBot.define do
  factory :user do
    email { "myemail@example.com" }
    password { "MyString" }

    trait :invalid_email do
      email { "wrongemail" }
    end

    trait :short_password do
      password { "12345" }
    end

    trait :second do
      email { "anothermail@example.com" }
      password { "MyString" }
    end
  end
end
