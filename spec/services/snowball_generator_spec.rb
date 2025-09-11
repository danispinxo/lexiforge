require 'rails_helper'

RSpec.describe SnowballGenerator do
  let(:source_text) do
    create(:source_text,
           content: 'I am the cat who walks by himself and all places are alike to me. I can walk through walls and swim through seas. I am a wonderful magical mystical cat.')
  end

  let(:generator) { described_class.new(source_text) }

  describe '#generate' do
    context 'with snowball method' do
      let(:options) { { method: 'snowball', num_lines: 8, min_word_length: 1 } }
      let(:result) { generator.generate(options) }

      it 'generates a snowball poem' do
        expect(result).to be_a(String)
        expect(result).not_to eq('Not enough words in source text')
        expect(result).not_to eq('Could not generate enough lines for snowball poem')
      end

      it 'has progressively longer words' do
        lines = result.split("\n")
        expect(lines.length).to be >= 3

        previous_length = 0
        lines.each do |line|
          word = line.strip
          expect(word.length).to be >= previous_length
          previous_length = word.length
        end
      end

      it 'uses words from the source text' do
        source_words = source_text.content.downcase.gsub(/[^\w\s]/, '').split.uniq
        lines = result.split("\n")

        lines.each do |line|
          word = line.strip
          expect(source_words).to include(word)
        end
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid') }.to raise_error('Invalid method: invalid. Only supported method: snowball')
      end
    end

    context 'with insufficient content' do
      let(:short_source_text) { create(:source_text, content: 'a b c') }
      let(:short_generator) { described_class.new(short_source_text) }

      it 'returns error message' do
        result = short_generator.generate
        expect(result).to eq('Not enough words in source text')
      end
    end

    context 'with custom options' do
      let(:options) { { method: 'snowball', num_lines: 5, min_word_length: 3 } }
      let(:result) { generator.generate(options) }

      it 'respects min_word_length option' do
        lines = result.split("\n")
        first_word = lines.first.strip
        expect(first_word.length).to be >= 3
      end

      it 'respects num_lines option when possible' do
        lines = result.split("\n")
        expect(lines.length).to be <= 5
      end
    end
  end
end
