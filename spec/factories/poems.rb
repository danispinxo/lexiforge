FactoryBot.define do
  factory :poem do
    association :source_text
    title { Faker::Book.title }
    content { Faker::Lorem.paragraphs(number: 2).join("\n") }
    is_public { true }
    technique_used { 'cutup' }

    trait :erasure_poem do
      technique_used { 'erasure' }
      content { Faker::Lorem.paragraphs(number: 1).join("\n") }
    end

    trait :blackout_poem do
      technique_used { 'blackout' }
      content do
        words = Faker::Lorem.words(number: 10)
        words.map.with_index do |word, index|
          index.even? ? word : "<span class='blackout-word'>██████</span>"
        end.join(' ')
      end
    end

    trait :cut_up_poem do
      technique_used { 'cutup' }
      content { Faker::Lorem.paragraphs(number: 2).join("\n") }
    end

    trait :mesostic_poem do
      technique_used { 'mesostic' }
      content { Faker::Lorem.paragraphs(number: 1).join("\n") }
    end

    trait :snowball_poem do
      technique_used { 'snowball' }
      content { Faker::Lorem.paragraphs(number: 1).join("\n") }
    end

    trait :beautiful_outlaw_poem do
      technique_used { 'beautiful_outlaw' }
      content do
        {
          type: 'beautiful_outlaw',
          hidden_word: 'LOVE',
          stanzas: [
            { number: 1, forbidden_letter: 'L', lines: ['Cherry words dance together', 'Bright harmony creates music'] },
            { number: 2, forbidden_letter: 'O', lines: ['Silent letters whisper truths', 'Ancient scripts reveal beauty'] },
            { number: 3, forbidden_letter: 'V', lines: ['Poetry flows through language', 'Words create magical stories'] },
            { number: 4, forbidden_letter: 'E', lines: ['Music flows through words', 'Art transforms ordinary things'] }
          ]
        }.to_json
      end
    end
  end
end
