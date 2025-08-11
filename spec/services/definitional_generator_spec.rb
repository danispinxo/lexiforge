require 'rails_helper'

RSpec.describe DefinitionalGenerator do
  let(:source_text) { create(:source_text, content: 'The quick brown fox jumps over the lazy dog while the cat sleeps peacefully in the warm sunshine.') }
  let(:generator) { DefinitionalGenerator.new(source_text) }

  before do
    DictionaryWord.find_or_create_by(word: 'quick', part_of_speech: 'adj') do |dw|
      dw.definition = 'moving fast or doing something in a short time'
    end
    DictionaryWord.find_or_create_by(word: 'brown', part_of_speech: 'adj') do |dw|
      dw.definition = 'of a color produced by mixing red, yellow, and black'
    end
    DictionaryWord.find_or_create_by(word: 'fox', part_of_speech: 'n') do |dw|
      dw.definition = 'alert carnivorous mammal with pointed muzzle and ears and a bushy tail; most are predators that do not hunt in packs'
    end
    DictionaryWord.find_or_create_by(word: 'jumps', part_of_speech: 'v') do |dw|
      dw.definition = 'to move quickly off the ground or away from a surface'
    end
    DictionaryWord.find_or_create_by(word: 'lazy', part_of_speech: 'adj') do |dw|
      dw.definition = 'not willing to work or use any effort'
    end
    DictionaryWord.find_or_create_by(word: 'dog', part_of_speech: 'n') do |dw|
      dw.definition = 'a common animal with four legs that is often kept as a pet'
    end
  end

  describe '#generate' do
    context 'with valid options' do
      it 'generates definitional text' do
        result = generator.generate(
          method: 'definitional',
          section_length: 10,
          words_to_replace: 3
        )

        expect(result).to be_a(String)
        expect(result).not_to eq('Not enough words in source text')
        expect(result.length).to be > 0
      end

      it 'handles insufficient words gracefully' do
        short_source = create(:source_text, content: 'Hi.')
        short_generator = DefinitionalGenerator.new(short_source)

        result = short_generator.generate(
          method: 'definitional',
          section_length: 10,
          words_to_replace: 5
        )

        expect(result).to eq('Not enough words in source text')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect do
          generator.generate(method: 'invalid_method')
        end.to raise_error('Invalid method: invalid_method')
      end
    end
  end

  describe 'private methods' do
    describe '#definition?' do
      it 'returns true for words with definitions' do
        expect(generator.send(:definition?, 'fox')).to be true
        expect(generator.send(:definition?, 'quick')).to be true
      end

      it 'returns false for words without definitions' do
        expect(generator.send(:definition?, 'xyz123')).to be false
      end

      it 'returns false for short words' do
        expect(generator.send(:definition?, 'a')).to be false
      end
    end

    describe '#find_definition_replacement' do
      it 'returns definition for valid word' do
        result = generator.send(:find_definition_replacement, 'fox')
        expect(result).to be_a(String)
        expect(result.length).to be > 0
        expect(result).to include('carnivorous mammal')
      end

      it 'returns nil for word without definition' do
        result = generator.send(:find_definition_replacement, 'xyz123')
        expect(result).to be_nil
      end

      it 'removes parentheses and their content' do
        DictionaryWord.find_or_create_by(word: 'test', part_of_speech: 'n') do |dw|
          dw.definition = 'the act (or trial) of testing something'
        end

        result = generator.send(:find_definition_replacement, 'test')
        expect(result).to eq('the act of testing something')
      end
    end
  end
end
