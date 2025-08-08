FactoryBot.define do
  factory :dictionary_word do
    sequence(:word) { |n| "word#{n}" }
    part_of_speech { %w[n v a r s].sample }
    definition { Faker::Lorem.sentence }
    synsets { [Faker::Lorem.word, Faker::Lorem.word, Faker::Lorem.word] }
  end

  factory :dictionary_word_noun, parent: :dictionary_word do
    part_of_speech { 'n' }
  end

  factory :dictionary_word_verb, parent: :dictionary_word do
    part_of_speech { 'v' }
  end

  factory :dictionary_word_adjective, parent: :dictionary_word do
    part_of_speech { 'a' }
  end
end
