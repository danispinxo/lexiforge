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
        [
          "Cherry words dance together\nBright harmony creates music",
          "Silent writing whispers truths\nAncient scripts show beauty",
          "Poetry flows through language\nWords create magical stories",
          "Music flows through words\nArt transforms ordinary things"
        ].join("\n\n")
      end
    end
  end
end
