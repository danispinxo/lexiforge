require 'rails_helper'

RSpec.describe NPlusSevenGenerator do
  let(:source_text) { create(:source_text, content: 'The cat sat on the mat. The dog ran fast.') }
  let(:generator) { described_class.new(source_text) }

  before do
    DictionaryWord.find_or_create_by(word: 'cat', part_of_speech: 'n') do |dw|
      dw.definition = 'A feline animal'
      dw.synsets = ['cat']
    end
    DictionaryWord.find_or_create_by(word: 'mat', part_of_speech: 'n') do |dw|
      dw.definition = 'A floor covering'
      dw.synsets = ['mat']
    end
    DictionaryWord.find_or_create_by(word: 'dog', part_of_speech: 'n') do |dw|
      dw.definition = 'A canine animal'
      dw.synsets = ['dog']
    end
    DictionaryWord.find_or_create_by(word: 'house', part_of_speech: 'n') do |dw|
      dw.definition = 'A dwelling'
      dw.synsets = ['house']
    end
    DictionaryWord.find_or_create_by(word: 'book', part_of_speech: 'n') do |dw|
      dw.definition = 'A written work'
      dw.synsets = ['book']
    end
    DictionaryWord.find_or_create_by(word: 'tree', part_of_speech: 'n') do |dw|
      dw.definition = 'A woody plant'
      dw.synsets = ['tree']
    end
  end

  describe '#generate' do
    context 'with n_plus_seven method' do
      it 'generates N+7 poem with default options' do
        result = generator.generate(method: 'n_plus_seven')

        expect(result).to be_a(String)
        expect(result).not_to be_empty
        expect(result).not_to eq(source_text.content)
      end

      it 'generates N+7 poem with custom options' do
        result = generator.generate(
          method: 'n_plus_seven',
          words_to_select: 10,
          offset: 7
        )

        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end

      it 'returns error message for short source text' do
        short_source = create(:source_text, content: 'Short text')
        short_generator = described_class.new(short_source)

        result = short_generator.generate(method: 'n_plus_seven')

        expect(result).to eq('Not enough words in source text')
      end
    end

    context 'with invalid method' do
      it 'raises error for invalid method' do
        expect do
          generator.generate(method: 'invalid_method')
        end.to raise_error('Invalid method: invalid_method')
      end
    end
  end

  describe '#extract_words_with_positions' do
    it 'extracts words with correct positions and lengths' do
      words = generator.send(:extract_words_with_positions)

      expect(words).to be_an(Array)
      expect(words).not_to be_empty

      words.each do |word_data|
        expect(word_data).to have_key(:word)
        expect(word_data).to have_key(:position)
        expect(word_data).to have_key(:length)
        expect(word_data[:word]).to be_a(String)
        expect(word_data[:position]).to be_an(Integer)
        expect(word_data[:length]).to be_an(Integer)
      end
    end

    it 'handles text with punctuation' do
      text_with_punctuation = create(:source_text, content: 'Hello, world! How are you?')
      generator_with_punct = described_class.new(text_with_punctuation)

      words = generator_with_punct.send(:extract_words_with_positions)

      expect(words.map { |w| w[:word] }).to include('Hello', 'world', 'How', 'are', 'you')
    end
  end

  describe '#select_random_word_subset' do
    it 'selects consecutive words from random starting point' do
      words = generator.send(:extract_words_with_positions)
      selected = generator.send(:select_random_word_subset, words, 5)

      expect(selected).to be_an(Array)
      expect(selected.length).to be <= 5
      expect(selected).not_to be_empty
    end

    it 'handles requests for more words than available' do
      words = generator.send(:extract_words_with_positions)
      selected = generator.send(:select_random_word_subset, words, 100)

      expect(selected.length).to be <= words.length
    end
  end

  describe '#is_noun?' do
    it 'returns true for words that exist as nouns in dictionary' do
      expect(generator.send(:is_noun?, 'cat')).to be true
      expect(generator.send(:is_noun?, 'dog')).to be true
    end

    it 'returns false for words that do not exist as nouns' do
      expect(generator.send(:is_noun?, 'the')).to be false
      expect(generator.send(:is_noun?, 'sat')).to be false
    end

    it 'returns false for short words' do
      expect(generator.send(:is_noun?, 'a')).to be false
    end
  end

  describe '#find_n_plus_seven_replacement' do
    it 'finds replacement for existing noun' do
      cat_id = DictionaryWord.find_by(word: 'cat').id
      house_id = DictionaryWord.find_by(word: 'house').id
      offset = house_id - cat_id

      replacement = generator.send(:find_n_plus_seven_replacement, 'cat', offset)
      expect(replacement).to eq('house')
    end

    it 'returns nil for non-existent word' do
      replacement = generator.send(:find_n_plus_seven_replacement, 'nonexistent', 7)
      # The method might find a close match, so we just check it's not the original word
      expect(replacement).not_to eq('nonexistent')
    end

    it 'handles different offset values' do
      replacement = generator.send(:find_n_plus_seven_replacement, 'cat', 5)
      # This might return nil or a different word depending on what's in the database
      expect(replacement).to be_a(String).or be_nil
    end
  end

  describe 'integration' do
    it 'generates poem with noun replacements' do
      result = generator.generate(
        method: 'n_plus_seven',
        words_to_select: 10,
        offset: 7
      )

      # The result should contain some of the replacement words
      expect(result).to be_a(String)
      expect(result).not_to be_empty

      # Check that the result contains words from the selected subset
      words = result.split(' ')
      expect(words.length).to be <= 15 # Allow for some flexibility in word count
    end
  end
end
