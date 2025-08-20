FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    username { Faker::Internet.unique.username(specifier: 3..30, separators: %w[_]) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    bio { Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 1) }
    password { Faker::Internet.password(min_length: 8) }
    password_confirmation { password }
  end
end
