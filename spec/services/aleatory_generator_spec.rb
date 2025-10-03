require 'rails_helper'

RSpec.describe AleatoryGenerator, type: :service do
  let(:source_text) { create(:source_text, :long_content) }
  let(:generator) { described_class.new(source_text) }

  describe '#initialize' do
    it 'accepts a source text' do
      expect(generator.instance_variable_get(:@source_text)).to eq(source_text)
    end
  end

  describe '#generate' do
    context 'with default method' do
      it 'calls generate_aleatory by default' do
        expect(generator).to receive(:generate_aleatory).with({})
        generator.generate
      end
    end

    context 'with aleatory method' do
      it 'calls generate_aleatory' do
        expect(generator).to receive(:generate_aleatory).with({ method: 'aleatory' })
        generator.generate(method: 'aleatory')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid') }.to raise_error('Invalid method: invalid. Only supported method: aleatory')
      end
    end
  end

  describe '#generate_aleatory' do
    context 'with valid options' do
      let(:options) do
        {
          method: 'aleatory',
          num_lines: 5,
          line_length: 'medium',
          randomness_factor: 0.8
        }
      end

      it 'generates aleatory poetry' do
        result = generator.generate(options)

        expect(result).to be_a(String)
        expect(result).not_to eq('Not enough words in source text')
        expect(result.length).to be > 0
      end

      it 'generates the correct number of lines' do
        result = generator.generate(options)
        lines = result.split("\n")
        expect(lines.length).to eq(5)
      end

      it 'uses words from the source text' do
        result = generator.generate(options)
        lines = result.split("\n")

        source_words = source_text.content.downcase.gsub(/[^\w\s]/, '').split

        lines.each do |line|
          line_words = line.downcase.gsub(/[^\w\s]/, '').split
          next if line_words.empty?

          line_words.each do |word|
            expect(source_words).to include(word)
          end
        end
      end

      it 'respects line length constraints' do
        result = generator.generate(options)
        lines = result.split("\n")

        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be_between(5, 7)
        end
      end
    end

    context 'with different randomness factors' do
      [0.0, 0.3, 0.7, 1.0].each do |factor|
        it "generates poetry with randomness factor #{factor}" do
          options = {
            method: 'aleatory',
            num_lines: 3,
            line_length: 'short',
            randomness_factor: factor
          }

          result = generator.generate(options)
          expect(result).to be_a(String)
          expect(result.length).to be > 0
        end
      end
    end

    context 'with different line lengths' do
      %w[very_short short medium long very_long].each do |length|
        it "generates poetry with #{length} line length" do
          options = {
            method: 'aleatory',
            num_lines: 3,
            line_length: length,
            randomness_factor: 0.5
          }

          result = generator.generate(options)
          expect(result).to be_a(String)
          expect(result.length).to be > 0
        end
      end
    end

    context 'with insufficient content' do
      let(:short_source) { create(:source_text, content: 'Hi there.') }
      let(:short_generator) { AleatoryGenerator.new(short_source) }

      it 'handles insufficient words gracefully' do
        options = {
          method: 'aleatory',
          num_lines: 10,
          line_length: 'medium',
          randomness_factor: 0.5
        }

        result = short_generator.generate(options)
        expect(result).to eq('Not enough words in source text')
      end
    end

    context 'with default options' do
      it 'uses default configuration' do
        result = generator.generate(method: 'aleatory')

        expect(result).to be_a(String)
        expect(result.length).to be > 0

        lines = result.split("\n")
        expect(lines.length).to eq(10)
      end
    end
  end

  describe '#default_method' do
    it 'returns aleatory' do
      expect(generator.send(:default_method)).to eq('aleatory')
    end
  end

  describe 'private methods' do
    describe '#calculate_word_range' do
      it 'returns correct range for very_short' do
        range = generator.send(:calculate_word_range, 'very_short')
        expect(range).to eq(1..2)
      end

      it 'returns correct range for short' do
        range = generator.send(:calculate_word_range, 'short')
        expect(range).to eq(3..4)
      end

      it 'returns correct range for medium' do
        range = generator.send(:calculate_word_range, 'medium')
        expect(range).to eq(5..7)
      end

      it 'returns correct range for long' do
        range = generator.send(:calculate_word_range, 'long')
        expect(range).to eq(8..10)
      end

      it 'returns correct range for very_long' do
        range = generator.send(:calculate_word_range, 'very_long')
        expect(range).to eq(10..15)
      end

      it 'defaults to medium for unknown length' do
        range = generator.send(:calculate_word_range, 'unknown')
        expect(range).to eq(5..7)
      end
    end
  end
end
