require 'rails_helper'

RSpec.describe ReverseLipogramGenerator, type: :service do
  let(:source_text) { create(:source_text, content: sample_content) }
  let(:sample_content) do
    'Aaa eee iii ooo uuu area idea audio. ' \
      'Eau eau eau eau eau eau eau eau eau eau. ' \
      'Oui oui oui oui oui oui oui oui oui oui.'
  end

  describe '#generate' do
    context 'with valid options' do
      let(:options) do
        {
          method: 'reverse_lipogram',
          num_words: 10,
          line_length: 'medium',
          letters_to_use: 'aeiou'
        }
      end

      it 'generates a reverse lipogram poem' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end

      it 'only uses words containing specified letters' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        words = result.downcase.gsub(/[^\w\s]/, '').split
        words.each do |word|
          expect(word.chars.all? { |char| 'aeiou'.include?(char) }).to be true
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

    context 'with consonants only' do
      let(:options) do
        {
          method: 'reverse_lipogram',
          num_words: 8,
          line_length: 'short',
          letters_to_use: 'bcdfg'
        }
      end

      it 'generates poem using only specified consonants' do
        consonant_source = create(:source_text, content: 'Bbb ccc ddd fff ggg bcf dgb cfg bcd fgd cdf bgf.')
        generator = described_class.new(consonant_source)
        result = generator.generate(options)

        words = result.downcase.gsub(/[^\w\s]/, '').split
        words.each do |word|
          expect(word.chars.all? { |char| 'bcdfg'.include?(char) }).to be true
        end
      end
    end

    context 'with invalid options' do
      it 'returns error when letters_to_use is empty' do
        options = {
          method: 'reverse_lipogram',
          num_words: 10,
          letters_to_use: ''
        }

        generator = described_class.new(source_text)
        result = generator.generate(options)

        expect(result).to include('Letters to use is required')
      end

      it 'returns error when letters_to_use contains non-alphabetic characters' do
        options = {
          method: 'reverse_lipogram',
          num_words: 10,
          letters_to_use: 'abc123'
        }

        generator = described_class.new(source_text)
        result = generator.generate(options)

        expect(result).to include('Letters to use must contain only alphabetic characters')
      end

      it 'returns error when not enough matching words available' do
        options = {
          method: 'reverse_lipogram',
          num_words: 100,
          letters_to_use: 'xyz'
        }

        generator = described_class.new(source_text)
        result = generator.generate(options)

        expect(result).to include('Not enough words available that contain only the specified letters')
      end
    end

    context 'with different line lengths' do
      %w[short medium long].each do |length|
        it "generates poem with #{length} line length" do
          options = {
            method: 'reverse_lipogram',
            num_words: 15,
            line_length: length,
            letters_to_use: 'aeiou'
          }

          generator = described_class.new(source_text)
          result = generator.generate(options)

          expect(result).to be_a(String)
          expect(result.lines.length).to be > 0
        end
      end
    end
  end

  describe '#default_method' do
    it 'returns reverse_lipogram' do
      generator = described_class.new(source_text)
      expect(generator.send(:default_method)).to eq('reverse_lipogram')
    end
  end
end
