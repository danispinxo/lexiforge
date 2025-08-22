require 'rails_helper'

RSpec.describe PrisonersConstraintGenerator, type: :service do
  let(:source_text) do
    create(:source_text, content: 'The quick brown fox jumps over the lazy dog. Amazing grace saves no one everywhere. Water ice cream cone magic occurs.')
  end
  let(:generator) { described_class.new(source_text) }

  describe '#generate' do
    context 'with default options (full constraint)' do
      let(:options) { {} }

      it 'handles insufficient words correctly' do
        result = generator.generate(options)

        expect(result).to eq('Not enough words in source text that meet the constraint')
      end
    end

    context 'with no_ascenders constraint' do
      let(:options) { { constraint_type: 'no_ascenders', num_words: 10 } }

      it 'generates words without ascenders' do
        result = generator.generate(options)
        words = result.split(/\s+/)

        expect(words.count).to eq(10)

        ascenders = %w[b d f h k l t]
        words.each do |word|
          expect(word.chars).not_to include(*ascenders)
        end

        expect(result.split("\n").count).to be > 1
      end
    end

    context 'with no_descenders constraint' do
      let(:options) { { constraint_type: 'no_descenders', num_words: 10 } }

      it 'generates words without descenders' do
        result = generator.generate(options)
        words = result.split(/\s+/)

        expect(words.count).to eq(10)

        descenders = %w[g j p q y]
        words.each do |word|
          expect(word.chars).not_to include(*descenders)
        end

        expect(result.split("\n").count).to be > 1
      end
    end

    context 'with full_constraint and smaller number' do
      let(:options) { { constraint_type: 'full_constraint', num_words: 5 } }

      it 'generates words without ascenders or descenders' do
        result = generator.generate(options)
        words = result.split(/\s+/)

        expect(words.count).to eq(5)

        prohibited_letters = %w[b d f g h j k l p q t y]
        words.each do |word|
          expect(word.chars).not_to include(*prohibited_letters)
        end

        expect(result.split("\n").count).to be > 1
      end
    end

    context 'with custom num_words that works' do
      let(:options) { { constraint_type: 'no_descenders', num_words: 7 } }

      it 'generates the specified number of words' do
        result = generator.generate(options)
        words = result.split(/\s+/)

        expect(words.count).to eq(7)

        expect(result.split("\n").count).to be > 1
      end
    end

    context 'when insufficient words meet constraint' do
      let(:source_text) { create(:source_text, content: 'by by by by by by by by by') }
      let(:options) { { constraint_type: 'full_constraint' } }

      it 'returns an error message' do
        result = generator.generate(options)

        expect(result).to eq('Not enough words in source text that meet the constraint')
      end
    end

    context 'with minimal source text' do
      let(:source_text) { create(:source_text, content: 'a') }

      it 'returns an error message for insufficient words' do
        result = generator.generate({})

        expect(result).to eq('Not enough words in source text that meet the constraint')
      end
    end
  end

  describe 'private methods' do
    describe '#filter_full_constraint' do
      it 'removes words with prohibited letters' do
        words = %w[water ice cream cone magic amazing grace saves one]
        filtered = generator.send(:filter_full_constraint, words)

        expect(filtered).to include('ice', 'cream', 'cone', 'saves', 'one')
        expect(filtered).not_to include('water', 'magic', 'amazing', 'grace')
      end
    end

    describe '#filter_no_ascenders' do
      it 'removes words with ascenders' do
        words = %w[water ice cream tall magic amazing grace saves one]
        filtered = generator.send(:filter_no_ascenders, words)

        expect(filtered).not_to include('water', 'tall')
        expect(filtered).to include('ice', 'cream', 'magic', 'amazing', 'grace', 'saves', 'one')
      end
    end

    describe '#filter_no_descenders' do
      it 'removes words with descenders' do
        words = %w[water ice cream happy magic amazing grace saves one]
        filtered = generator.send(:filter_no_descenders, words)

        expect(filtered).not_to include('happy', 'magic', 'amazing', 'grace')
        expect(filtered).to include('water', 'ice', 'cream', 'saves', 'one')
      end
    end

    describe '#lineate_words' do
      it 'returns single line for 3 or fewer words' do
        words = %w[one two three]
        result = generator.send(:lineate_words, words)

        expect(result).to eq('one two three')
        expect(result.split("\n").count).to eq(1)
      end

      it 'creates multiple lines for more words' do
        words = %w[one two three four five six seven eight]
        result = generator.send(:lineate_words, words)

        lines = result.split("\n")
        expect(lines.count).to be > 1

        all_words_in_result = result.split(/\s+/)
        expect(all_words_in_result.sort).to eq(words.sort)
      end

      it 'varies line lengths appropriately' do
        words = %w[one two three four five six seven eight nine ten]
        result = generator.send(:lineate_words, words)

        lines = result.split("\n")
        line_lengths = lines.map { |line| line.split.count }

        expect(line_lengths.all? { |length| length.between?(1, 4) }).to be true
        expect(line_lengths.sum).to eq(words.count)
      end
    end

    describe '#extract_clean_words' do
      let(:source_text_with_numbers) do
        create(:source_text, content: "Hello world123 test-case 42 amazing grace 3rd edition won't work!")
      end
      let(:generator_with_numbers) { described_class.new(source_text_with_numbers) }

      it 'removes words with numbers and punctuation' do
        clean_words = generator_with_numbers.send(:extract_clean_words)

        expect(clean_words).to include('hello', 'amazing', 'grace', 'work')
        expect(clean_words).not_to include('world123', '42', '3rd')

        clean_words.each do |word|
          expect(word).to match(/\A[a-z]+\z/)
        end
      end
    end
  end
end
