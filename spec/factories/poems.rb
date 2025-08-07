FactoryBot.define do
  factory :poem do
    association :source_text
    title { 'Generated Poem' }
    content { "This is a generated poem\nwith multiple lines\nand interesting words" }
    technique_used { 'cutup' }

    trait :erasure_poem do
      technique_used { 'erasure' }
      content { 'This is an erasure poem with some words     removed and others kept intact.' }
    end

    trait :blackout_poem do
      technique_used { 'blackout' }
      content do
        "This is a <span class='blackout-word'>██████</span> poem with <span class='blackout-word'>████</span> words blacked out."
      end
    end

    trait :cut_up_poem do
      technique_used { 'cutup' }
      content { "random words\ncut up lines\nmixed together\nfrom source text" }
    end
  end
end
