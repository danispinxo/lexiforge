FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { 'adminpassword123' }
    password_confirmation { 'adminpassword123' }

    trait :super_admin do
      email { 'superadmin@example.com' }
    end

    trait :with_comments do
      after(:create) do |admin_user|
        create_list(:active_admin_comment, 3, author: admin_user)
      end
    end
  end
end
