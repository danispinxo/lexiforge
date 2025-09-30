FactoryBot.define do
  factory :source_text do
    title { Faker::Book.title }
    content { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    gutenberg_id { nil }

    trait :with_gutenberg_id do
      sequence(:gutenberg_id) { |n| n + 10_000 }
      is_public { false }  # Set to private to avoid uniqueness conflicts with Gutenberg IDs
    end

    trait :short_content do
      content { Faker::Lorem.sentence(word_count: 5) }
    end

    trait :long_content do
      content { Faker::Lorem.paragraphs(number: 20).join("\n\n") }
    end

    trait :empty_content do
      content { '' }
      to_create { |instance| instance.save(validate: false) }
    end

    trait :classic_literature do
      title { Faker::Book.title }
      content { Faker::Lorem.paragraphs(number: 10).join("\n\n") }
      sequence(:gutenberg_id) { |n| n + 20_000 }
      is_public { false }  # Set to private to avoid uniqueness conflicts with Gutenberg IDs
    end

    trait :poetry do
      title { Faker::Book.title }
      content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    end
  end
end
