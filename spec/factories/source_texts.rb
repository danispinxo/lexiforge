FactoryBot.define do
  factory :source_text do
    title { 'Sample Text' }
    content do
      'This is a sample text with enough words to generate poems from. It contains multiple sentences and paragraphs to test various scenarios. The text should be long enough to provide sufficient material for cut-up and erasure poetry generation.'
    end
    gutenberg_id { nil }

    trait :with_gutenberg_id do
      gutenberg_id { 1234 }
    end

    trait :short_content do
      content { 'Short text' }
    end

    trait :long_content do
      content do
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ' \
          'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ' \
          'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. ' \
          'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. ' \
          'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, ' \
          'eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. ' \
          'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.'
      end
    end

    trait :empty_content do
      content { '' }
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
