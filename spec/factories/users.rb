FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_poems do
      after(:create) do |user|
        create_list(:poem, 3, user: user)
      end
    end

    trait :with_source_texts do
      after(:create) do |user|
        create_list(:source_text, 2, user: user)
      end
    end
  end
end
