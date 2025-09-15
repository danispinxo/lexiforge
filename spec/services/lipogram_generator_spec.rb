require 'rails_helper'

RSpec.describe LipogramGenerator do
  let(:source_text) { create(:source_text, :long_content) }
  let(:generator) { described_class.new(source_text) }

  describe '#initialize' do
    it 'accepts a source text' do
      expect(generator.instance_variable_get(:@source_text)).to eq(source_text)
    end
  end

  describe '#generate' do
    context 'with default method' do
      it 'calls generate_lipogram by default' do
        expect(generator).to receive(:generate_lipogram).with({})
        generator.generate
      end
    end

    context 'with lipogram method' do
      it 'calls generate_lipogram' do
        expect(generator).to receive(:generate_lipogram).with({ method: 'lipogram' })
        generator.generate(method: 'lipogram')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid') }.to raise_error('Invalid method: invalid. Only supported method: lipogram')
      end
    end
  end

  describe '#generate_lipogram' do
    let(:result) { generator.send(:generate_lipogram, options) }

    context 'with default options' do
      let(:options) { {} }

      it 'generates lipogram poem with default settings' do
        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end

      it 'omits the default letter (e) from all words' do
        result_words = result.downcase.split
        result_words.each do |word|
          expect(word).not_to include('e')
        end
      end

      it 'uses only words from source text' do
        source_words = source_text.content.downcase
                                  .gsub(/[^\w\s]/, '')
                                  .split
                                  .reject { |word| word.length < 2 }
                                  .uniq

        result_words = result.downcase.split
        result_words.each do |word|
          expect(source_words).to include(word)
        end
      end
    end

    context 'with custom options' do
      let(:options) { { num_words: 15, line_length: 'short', letters_to_omit: 'a' } }

      it 'respects custom word count' do
        word_count = result.split.length
        expect(word_count).to be <= 15
        expect(word_count).to be > 0
      end

      it 'omits the specified letter' do
        result_words = result.downcase.split
        result_words.each do |word|
          expect(word).not_to include('a')
        end
      end

      it 'uses short line lengths' do
        lines = result.lines.map(&:strip)
        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be_between(3, 4)
        end
      end
    end

    context 'with single letter to omit' do
      let(:source_text) { create(:source_text, content: 'cat dog bird fish mouse rabbit') }
      let(:options) { { letters_to_omit: 'a' } }

      it 'omits the specified letter' do
        result_words = result.downcase.split
        result_words.each do |word|
          expect(word).not_to include('a')
        end
      end
    end

    context 'with different line lengths' do
      %w[short medium long].each do |line_length|
        context "with #{line_length} line length" do
          let(:options) { { line_length: line_length, letters_to_omit: 'e' } }

          it "generates appropriate word ranges for #{line_length}" do
            lines = result.lines.map(&:strip)
            lines.each do |line|
              word_count = line.split.length
              case line_length
              when 'short'
                expect(word_count).to be_between(3, 4)
              when 'medium'
                expect(word_count).to be_between(5, 7)
              when 'long'
                expect(word_count).to be_between(8, 10)
              end
            end
          end
        end
      end
    end

    context 'with insufficient source words' do
      let(:source_text) { create(:source_text, content: 'a b c') }
      let(:options) { {} }

      it 'returns error message for insufficient words' do
        expect(result).to eq('Not enough words in source text')
      end
    end

    context 'with no words available after filtering' do
      let(:source_text) { create(:source_text, content: 'every evening everyone everywhere hello world') }
      let(:options) { { letters_to_omit: 'e' } }

      it 'returns error message for insufficient filtered words' do
        expect(result).to eq('Not enough words available after filtering by omitted letters')
      end
    end

    context 'with invalid letters_to_omit' do
      let(:options) { { letters_to_omit: '' } }

      it 'returns error for empty letters' do
        expect(result).to eq('Letter to omit is required')
      end
    end

    context 'with too many letters to omit' do
      let(:options) { { letters_to_omit: 'ab' } }

      it 'returns error for more than 1 letter' do
        expect(result).to eq('Letter to omit must be exactly one letter')
      end
    end

    context 'with non-alphabetic characters in letters_to_omit' do
      let(:options) { { letters_to_omit: 'a1b' } }

      it 'returns error for non-alphabetic characters' do
        expect(result).to eq('Letter to omit must be an alphabetic character')
      end
    end

    context 'with case insensitive letter omission' do
      let(:source_text) { create(:source_text, content: 'Apple Banana Cherry Date') }
      let(:options) { { letters_to_omit: 'A' } }

      it 'omits both uppercase and lowercase versions' do
        result_words = result.downcase.split
        result_words.each do |word|
          expect(word).not_to include('a')
        end
      end
    end

    context 'with punctuation in source text' do
      let(:source_text) { create(:source_text, content: 'Hello, world! This is a test... with punctuation?') }
      let(:options) { { letters_to_omit: 'e' } }

      it 'removes punctuation from words' do
        expect(result).not_to include(',', '!', '...', '?')
      end

      it 'still generates valid content' do
        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end
    end

    context 'with duplicate words in source' do
      let(:source_text) { create(:source_text, content: 'hello world hello world test test sample sample') }
      let(:options) { { letters_to_omit: 'e' } }

      it 'uses unique words only' do
        source_words = result.split.uniq
        all_words = result.split

        expect(source_words.length).to be <= all_words.length
      end
    end

    context 'randomization' do
      let(:options) { { num_words: 10, letters_to_omit: 'e' } }

      it 'produces different results on multiple runs' do
        results = Array.new(5) { generator.send(:generate_lipogram, options) }

        expect(results.uniq.length).to be > 1
      end
    end

    context 'with exact word count' do
      let(:options) { { num_words: 5, letters_to_omit: 'e' } }

      it 'generates exactly the requested number of words' do
        word_count = result.split.length
        expect(word_count).to eq(5)
      end
    end

    context 'with more words requested than available' do
      let(:source_text) { create(:source_text, content: 'cat dog bird fish') }
      let(:options) { { num_words: 10, letters_to_omit: 'e' } }

      it 'uses all available words' do
        word_count = result.split.length
        expect(word_count).to be <= 4
        expect(word_count).to be > 0
      end
    end
  end

  describe 'word filtering logic' do
    let(:generator) { described_class.new(source_text) }

    context 'letter filtering' do
      let(:source_text) { create(:source_text, content: 'apple banana cherry date elderberry') }

      it 'correctly filters words containing omitted letter' do
        filtered_words = generator.send(:filter_words_by_omitted_letters,
                                        %w[apple banana cherry date elderberry], 'a')

        expect(filtered_words).to eq(['cherry'])
      end
    end

    context 'case insensitive filtering' do
      let(:source_text) { create(:source_text, content: 'Apple Banana Cherry') }

      it 'filters regardless of case' do
        filtered_words = generator.send(:filter_words_by_omitted_letters,
                                        %w[Apple Banana Cherry], 'a')

        expect(filtered_words).to eq(['Cherry'])
      end
    end
  end

  describe 'validation methods' do
    let(:generator) { described_class.new(source_text) }

    describe '#validate_letters_to_omit' do
      it 'validates required parameter' do
        result = generator.send(:validate_letters_to_omit, nil)
        expect(result).to eq('Letter to omit is required')
      end

      it 'validates length constraints' do
        result = generator.send(:validate_letters_to_omit, '')
        expect(result).to eq('Letter to omit is required')
      end

      it 'validates alphabetic characters only' do
        result = generator.send(:validate_letters_to_omit, '1')
        expect(result).to eq('Letter to omit must be an alphabetic character')
      end

      it 'returns nil for valid input' do
        result = generator.send(:validate_letters_to_omit, 'a')
        expect(result).to be_nil
      end
    end

    describe '#validate_filtered_words' do
      it 'validates sufficient filtered words' do
        result = generator.send(:validate_filtered_words, %w[word1 word2], 5)
        expect(result).to eq('Not enough words available after filtering by omitted letters')
      end

      it 'returns nil for sufficient words' do
        result = generator.send(:validate_filtered_words, %w[word1 word2 word3], 2)
        expect(result).to be_nil
      end
    end
  end
end
