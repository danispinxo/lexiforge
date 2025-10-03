require 'rails_helper'

RSpec.describe AlliterativeGenerator, type: :service do
  let(:source_text) { create(:source_text, content: sample_content) }
  let(:generator) { described_class.new(source_text) }
  let(:sample_content) do
    'Amazing apples are always available. Ancient artifacts attract attention. ' \
      'Artistic artists arrange arrangements. Awesome adventures await ahead. ' \
      'Amazing animals appear around areas. Artistic architecture attracts admiration. ' \
      'Ancient ancestors achieved amazing accomplishments. Awesome achievements await ambitious artists. ' \
      'Amazing adventures await around amazing areas. Artistic arrangements attract attention. ' \
      'Ancient artifacts are amazing achievements. Awesome artists arrange amazing art. ' \
      'Amazing animals are awesome and amazing. Artistic architecture is amazing and awesome. ' \
      'Amazing apples are always available. Ancient artifacts attract attention. ' \
      'Artistic artists arrange arrangements. Awesome adventures await ahead. ' \
      'Amazing animals appear around areas. Artistic architecture attracts admiration. ' \
      'Ancient ancestors achieved amazing accomplishments. Awesome achievements await ambitious artists.'
  end

  describe '#initialize' do
    it 'accepts a source text' do
      expect(generator.instance_variable_get(:@source_text)).to eq(source_text)
    end
  end

  describe '#generate' do
    context 'with default method' do
      it 'calls generate_alliterative by default' do
        expect(generator).to receive(:generate_alliterative).with({})
        generator.generate
      end
    end

    context 'with alliterative method' do
      it 'calls generate_alliterative' do
        expect(generator).to receive(:generate_alliterative).with({ method: 'alliterative' })
        generator.generate(method: 'alliterative')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid') }.to raise_error('Invalid method: invalid. Only supported method: alliterative')
      end
    end
  end

  describe '#generate_alliterative' do
    context 'with valid options' do
      let(:options) do
        {
          method: 'alliterative',
          num_lines: 5,
          line_length: 'medium',
          alliteration_letter: 'a'
        }
      end

      it 'generates alliterative poetry' do
        result = generator.generate(options)

        expect(result).to be_a(String)
        expect(result).not_to eq('Not enough words in source text')
        expect(result.length).to be > 0
      end

      it 'uses only words starting with the specified letter' do
        result = generator.generate(options)
        lines = result.split("\n")

        lines.each do |line|
          line_words = line.downcase.gsub(/[^\w\s]/, '').split
          line_words.each do |word|
            expect(word).to start_with('a')
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

      it 'uses words from the source text' do
        result = generator.generate(options)
        lines = result.split("\n")

        source_words = sample_content.downcase.gsub(/[^\w\s]/, '').split

        lines.each do |line|
          line_words = line.downcase.gsub(/[^\w\s]/, '').split
          line_words.each do |word|
            expect(source_words).to include(word)
          end
        end
      end
    end

    context 'with different alliteration letters' do
      it "generates alliterative poetry with letter 'a'" do
        options = {
          method: 'alliterative',
          num_lines: 3,
          line_length: 'short',
          alliteration_letter: 'a'
        }

        result = generator.generate(options)
        expect(result).not_to eq('Not enough words available that start with the specified letter')

        lines = result.split("\n")
        lines.each do |line|
          line_words = line.downcase.gsub(/[^\w\s]/, '').split
          line_words.each do |word|
            expect(word).to start_with('a')
          end
        end
      end

      it 'handles letters with no matching words gracefully' do
        options = {
          method: 'alliterative',
          num_lines: 3,
          line_length: 'short',
          alliteration_letter: 'z'
        }

        result = generator.generate(options)
        expect(result).to eq('Not enough words available that start with the specified letter')
      end
    end

    context 'with different line lengths' do
      %w[very_short short medium long very_long].each do |length|
        it "generates poetry with #{length} line length" do
          options = {
            method: 'alliterative',
            num_lines: 4,
            line_length: length,
            alliteration_letter: 'a'
          }

          result = generator.generate(options)
          expect(result).to be_a(String)
          expect(result.length).to be > 0
        end
      end
    end

    context 'with insufficient content' do
      let(:short_source) { create(:source_text, content: 'Hi there.') }
      let(:short_generator) { AlliterativeGenerator.new(short_source) }

      it 'handles insufficient words gracefully' do
        options = {
          method: 'alliterative',
          num_lines: 10,
          line_length: 'medium',
          alliteration_letter: 'a'
        }

        result = short_generator.generate(options)
        expect(result).to eq('Not enough words in source text')
      end
    end

    context 'with no words starting with specified letter' do
      let(:limited_source) { create(:source_text, content: 'Beautiful birds bring bright blessings. Creative cats climb carefully. Dogs dance delightfully during dawn. Elephants eat enormous amounts of food. Fish fly through flowing water. Great green grass grows everywhere. Happy horses hop around fields.') }
      let(:limited_generator) { AlliterativeGenerator.new(limited_source) }

      it 'handles no matching words gracefully' do
        options = {
          method: 'alliterative',
          num_lines: 5,
          line_length: 'medium',
          alliteration_letter: 'z'
        }

        result = limited_generator.generate(options)
        expect(result).to eq('Not enough words available that start with the specified letter')
      end
    end

    context 'with default options' do
      it 'uses default configuration' do
        result = generator.generate(method: 'alliterative')

        expect(result).to be_a(String)
        expect(result.length).to be > 0

        lines = result.split("\n")
        expect(lines.length).to eq(8)
      end
    end
  end

  describe '#default_method' do
    it 'returns alliterative' do
      expect(generator.send(:default_method)).to eq('alliterative')
    end
  end

  describe 'private methods' do
    describe '#validate_alliteration_letter' do
      it 'validates single letter' do
        result = generator.send(:validate_alliteration_letter, 'a')
        expect(result).to be_nil
      end

      it 'rejects blank letter' do
        result = generator.send(:validate_alliteration_letter, '')
        expect(result).to eq('Alliteration letter is required')
      end

      it 'rejects multiple letters' do
        result = generator.send(:validate_alliteration_letter, 'ab')
        expect(result).to eq('Alliteration letter must be a single letter')
      end

      it 'rejects non-alphabetic characters' do
        result = generator.send(:validate_alliteration_letter, '1')
        expect(result).to eq('Alliteration letter must be alphabetic')
      end
    end

    describe '#filter_words_by_alliteration' do
      let(:words) { %w[apple banana cherry date elephant] }

      it 'filters words starting with specified letter' do
        filtered = generator.send(:filter_words_by_alliteration, words, 'a')
        expect(filtered).to eq(%w[apple])
      end

      it 'filters words starting with specified letter (case insensitive)' do
        filtered = generator.send(:filter_words_by_alliteration, words, 'A')
        expect(filtered).to eq(%w[apple])
      end

      it 'returns empty array when no words match' do
        filtered = generator.send(:filter_words_by_alliteration, words, 'z')
        expect(filtered).to eq([])
      end
    end

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
