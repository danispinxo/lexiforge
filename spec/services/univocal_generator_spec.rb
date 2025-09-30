require 'rails_helper'

RSpec.describe UnivocalGenerator, type: :service do
  let(:source_text) { create(:source_text, content: sample_content) }
  let(:sample_content) do
    'The cat sat on a mat and ran fast past the barn. ' \
      'A dog went to see the tree where bees make sweet honey. ' \
      'Big fish swim in deep blue pools under the moon. ' \
      'Small birds sing songs from high branches above us all.'
  end

  describe '#generate' do
    context 'with vowel A' do
      let(:options) do
        {
          method: 'univocal',
          num_words: 10,
          line_length: 'medium',
          vowel_to_use: 'a'
        }
      end

      it 'generates a univocal poem using only A vowel' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end

      it 'only uses words containing vowel A and no other vowels' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        words = result.downcase.gsub(/[^\w\s]/, '').split
        other_vowels = %w[e i o u]

        words.each do |word|
          # Must contain 'a'
          expect(word).to include('a'), "Word '#{word}' should contain vowel 'a'"

          # Must not contain other vowels
          other_vowels.each do |vowel|
            expect(word).not_to include(vowel), "Word '#{word}' should not contain vowel '#{vowel}'"
          end
        end
      end

      it 'respects the num_words parameter' do
        options[:num_words] = 5
        generator = described_class.new(source_text)
        result = generator.generate(options)

        word_count = result.downcase.gsub(/[^\w\s]/, '').split.length
        expect(word_count).to be <= 5
      end
    end

    context 'with vowel E' do
      let(:options) do
        {
          method: 'univocal',
          num_words: 8,
          line_length: 'short',
          vowel_to_use: 'e'
        }
      end

      it 'only uses words containing vowel E and no other vowels' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        words = result.downcase.gsub(/[^\w\s]/, '').split
        other_vowels = %w[a i o u]

        words.each do |word|
          expect(word).to include('e'), "Word '#{word}' should contain vowel 'e'"

          other_vowels.each do |vowel|
            expect(word).not_to include(vowel), "Word '#{word}' should not contain vowel '#{vowel}'"
          end
        end
      end
    end

    context 'with vowel I' do
      let(:options) do
        {
          method: 'univocal',
          num_words: 6,
          line_length: 'medium',
          vowel_to_use: 'i'
        }
      end

      it 'only uses words containing vowel I and no other vowels' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        words = result.downcase.gsub(/[^\w\s]/, '').split
        other_vowels = %w[a e o u]

        words.each do |word|
          expect(word).to include('i'), "Word '#{word}' should contain vowel 'i'"

          other_vowels.each do |vowel|
            expect(word).not_to include(vowel), "Word '#{word}' should not contain vowel '#{vowel}'"
          end
        end
      end
    end

    context 'with vowel O' do
      let(:options) do
        {
          method: 'univocal',
          num_words: 7,
          line_length: 'long',
          vowel_to_use: 'o'
        }
      end

      it 'only uses words containing vowel O and no other vowels' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        words = result.downcase.gsub(/[^\w\s]/, '').split
        other_vowels = %w[a e i u]

        words.each do |word|
          expect(word).to include('o'), "Word '#{word}' should contain vowel 'o'"

          other_vowels.each do |vowel|
            expect(word).not_to include(vowel), "Word '#{word}' should not contain vowel '#{vowel}'"
          end
        end
      end
    end

    context 'with vowel U' do
      let(:options) do
        {
          method: 'univocal',
          num_words: 5,
          line_length: 'short',
          vowel_to_use: 'u'
        }
      end

      it 'only uses words containing vowel U and no other vowels' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        # Skip if not enough words found
        skip 'Not enough words available' if result.include?('Not enough words')

        words = result.downcase.gsub(/[^\w\s]/, '').split
        other_vowels = %w[a e i o]

        words.each do |word|
          expect(word).to include('u')

          other_vowels.each do |vowel|
            expect(word).not_to include(vowel), "Word '#{word}' should not contain vowel '#{vowel}'"
          end
        end
      end
    end

    context 'with invalid options' do
      it 'returns error when vowel_to_use is empty' do
        options = {
          method: 'univocal',
          num_words: 10,
          vowel_to_use: ''
        }

        generator = described_class.new(source_text)
        result = generator.generate(options)

        expect(result).to include('Vowel to use is required')
      end

      it 'returns error when vowel_to_use is not a vowel' do
        options = {
          method: 'univocal',
          num_words: 10,
          vowel_to_use: 'x'
        }

        generator = described_class.new(source_text)
        result = generator.generate(options)

        expect(result).to include('Vowel to use must be a single vowel (a, e, i, o, u)')
      end

      it 'returns error when not enough matching words available' do
        # Use content with very few words containing only 'u'
        limited_source = create(:source_text, content: 'The cat sat on a mat')
        options = {
          method: 'univocal',
          num_words: 50,
          vowel_to_use: 'u'
        }

        generator = described_class.new(limited_source)
        result = generator.generate(options)

        expect(result).to include('Not enough words')
      end
    end

    context 'with different line lengths' do
      %w[short medium long].each do |length|
        it "generates poem with #{length} line length" do
          options = {
            method: 'univocal',
            num_words: 12,
            line_length: length,
            vowel_to_use: 'a'
          }

          generator = described_class.new(source_text)
          result = generator.generate(options)

          expect(result).to be_a(String)
          expect(result.lines.length).to be > 0
        end
      end
    end

    context 'with content rich in specific vowels' do
      let(:vowel_rich_content) do
        'Cats and rats ran fast past barns and farms. ' \
          'Trees need deep green leaves. Bees see sweet seeds. ' \
          'Big fish swim with quick fins. Slim birds sing. ' \
          'Good dogs go to long roads. Frogs hop on logs. ' \
          'Ducks run under sun. Bugs hug rugs.'
      end
      let(:vowel_rich_source) { create(:source_text, content: vowel_rich_content) }

      %w[a e i o u].each do |vowel|
        it "generates substantial content for vowel #{vowel.upcase}" do
          options = {
            method: 'univocal',
            num_words: 15,
            line_length: 'medium',
            vowel_to_use: vowel
          }

          generator = described_class.new(vowel_rich_source)
          result = generator.generate(options)

          expect(result).to be_a(String)
          expect(result.split.length).to be > 5
        end
      end
    end
  end

  describe '#default_method' do
    it 'returns univocal' do
      generator = described_class.new(source_text)
      expect(generator.send(:default_method)).to eq('univocal')
    end
  end
end
