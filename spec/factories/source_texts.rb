FactoryBot.define do
  factory :source_text do
    title { Faker::Book.title }
    content { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    gutenberg_id { nil }

    trait :with_gutenberg_id do
      gutenberg_id { Faker::Number.between(from: 1000, to: 99_999) }
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
      gutenberg_id { Faker::Number.between(from: 1000, to: 99_999) }
    end

    trait :poetry do
      title { Faker::Book.title }
      content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    end
  end
end
