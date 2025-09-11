require 'rails_helper'

RSpec.describe FoundPoemGenerator do
  let(:source_text) { create(:source_text, content: sample_content) }
  let(:generator) { described_class.new(source_text) }

  let(:sample_content) do
    'The quick brown fox jumps over the lazy dog. ' \
      'A journey of a thousand miles begins with a single step. ' \
      'All that glitters is not gold. ' \
      'The early bird catches the worm. ' \
      'Actions speak louder than words. ' \
      'Beauty is in the eye of the beholder. ' \
      "Don't judge a book by its cover. " \
      'Every cloud has a silver lining. ' \
      'Fortune favors the bold. ' \
      'Good things come to those who wait.'
  end

  describe '#generate' do
    context 'with default options' do
      it 'generates a found poem with default settings' do
        result = generator.generate
        lines = result.split("\n")

        expect(lines.length).to be >= 8
        expect(lines.length).to be <= 12
        lines.each do |line|
          expect(line).to match(/^[A-Z]/) # Should be capitalized
          expect(line.split.length).to be >= 5
          expect(line.split.length).to be <= 7
        end
      end
    end

    context 'with custom number of lines' do
      it 'generates the specified number of lines' do
        result = generator.generate(num_lines: 5)
        lines = result.split("\n")

        expect(lines.length).to eq(5)
      end
    end

    context 'with different line lengths' do
      it 'generates very short lines (1-2 words)' do
        result = generator.generate(line_length: 'very_short')
        lines = result.split("\n")

        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be >= 1
          expect(word_count).to be <= 2
        end
      end

      it 'generates short lines (3-4 words)' do
        result = generator.generate(line_length: 'short')
        lines = result.split("\n")

        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be >= 3
          expect(word_count).to be <= 4
        end
      end

      it 'generates medium lines (5-7 words)' do
        result = generator.generate(line_length: 'medium')
        lines = result.split("\n")

        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be >= 5
          expect(word_count).to be <= 7
        end
      end

      it 'generates long lines (8-10 words)' do
        result = generator.generate(line_length: 'long')
        lines = result.split("\n")

        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be >= 8
          expect(word_count).to be <= 10
        end
      end

      it 'generates very long lines (10-15 words)' do
        result = generator.generate(line_length: 'very_long')
        lines = result.split("\n")

        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be >= 10
          expect(word_count).to be <= 15
        end
      end
    end

    context 'with insufficient content' do
      let(:source_text) { create(:source_text, content: 'Too short') }

      it 'returns an error message' do
        result = generator.generate
        expect(result).to eq('Not enough words in source text')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid') }.to raise_error('Invalid method: invalid. Only supported method: found')
      end
    end

    context 'line diversity' do
      it 'generates lines from different sections of the text' do
        result = generator.generate(num_lines: 10, line_length: 'short')
        lines = result.split("\n")

        # Check that we have some variety in the lines
        unique_lines = lines.uniq
        expect(unique_lines.length).to be > 1
      end
    end
  end
end
