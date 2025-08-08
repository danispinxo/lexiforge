FactoryBot.define do
  factory :admin_user do
    email { Faker::Internet.unique.email(domain: 'admin.com') }
    password { Faker::Internet.password(min_length: 10) }
    password_confirmation { password }

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
