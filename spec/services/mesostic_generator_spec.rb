require 'rails_helper'

RSpec.describe MesosticGenerator do
  let(:source_text) { create(:source_text, :long_content) }
  let(:generator) { described_class.new(source_text) }

  describe '#initialize' do
    it 'accepts a source text' do
      expect(generator.instance_variable_get(:@source_text)).to eq(source_text)
    end
  end

  describe '#generate' do
    context 'with default method' do
      it 'calls generate_mesostic by default' do
        expect(generator).to receive(:generate_mesostic).with({})
        generator.generate
      end
    end

    context 'with mesostic method' do
      it 'calls generate_mesostic' do
        expect(generator).to receive(:generate_mesostic).with({ method: 'mesostic' })
        generator.generate(method: 'mesostic')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid') }.to raise_error('Invalid method: invalid')
      end
    end
  end

  describe '#generate_mesostic' do
    let(:result) { generator.send(:generate_mesostic, options) }

    context 'with valid spine word' do
      let(:source_text) { create(:source_text, content: 'dog cat bird fish tree flower dragon world magic star dream') }
      let(:options) { { spine_word: 'dog' } }

      it 'generates mesostic poem with correct structure' do
        expect(result).to be_a(String)
        expect(result.lines.count).to eq(3)
        expect(result).not_to be_empty
      end

      it 'finds words with correct letters at correct positions' do
        lines = result.lines.map(&:strip)
        expect(lines[0]).to start_with('d')
        expect(lines[1][1]).to eq('o')
        expect(lines[2][2]).to eq('g')
      end
    end

    context 'with spine word containing spaces (stanza breaks)' do
      let(:source_text) { create(:source_text, content: 'dog cat bird fish tree flower dragon world magic star dream') }
      let(:options) { { spine_word: 'dog cat' } }

      it 'creates separate stanzas for each word' do
        expect(result).to be_a(String)
        lines = result.lines.map(&:strip)

        expect(lines.length).to eq(7)

        expect(lines[0]).to start_with('d')
        expect(lines[1][1]).to eq('o')
        expect(lines[2][2]).to eq('g')

        expect(lines[3]).to eq('')

        expect(lines[4]).to start_with('c')
        expect(lines[5][1]).to eq('a')
        expect(lines[6][2]).to eq('t')
      end
    end

    context 'with multiple spaces in spine word' do
      let(:source_text) { create(:source_text, content: 'dog cat bird fish tree flower dragon world magic star dream') }
      let(:options) { { spine_word: 'dog  cat' } }

      it 'treats multiple spaces as single stanza breaks' do
        expect(result).to be_a(String)
        lines = result.lines.map(&:strip)

        expect(lines.length).to eq(7)

        expect(lines[3]).to eq('')
      end
    end

    context 'with no matches in second stanza' do
      let(:source_text) { create(:source_text, content: 'dog cat bird fish tree flower dragon world magic star dream') }
      let(:options) { { spine_word: 'dog xyz' } }

      it 'only does one stanza if the second stanza fails entirely' do
        expect(result).to be_a(String)
        lines = result.lines.map(&:strip)

        expect(lines.length).to eq(3)

        expect(lines[0]).to start_with('d')
        expect(lines[1][1]).to eq('o')
        expect(lines[2][2]).to eq('g')
      end
    end

    context 'with missing spine word' do
      let(:options) { {} }

      it 'returns error message' do
        expect(result).to eq('Spine word is required for mesostic generation')
      end
    end

    context 'with blank spine word' do
      let(:options) { { spine_word: '' } }

      it 'returns error message' do
        expect(result).to eq('Spine word is required for mesostic generation')
      end
    end

    context 'with insufficient source words' do
      let(:source_text) { create(:source_text, content: 'a b c') }
      let(:options) { { spine_word: 'dog' } }

      it 'returns error message for insufficient words' do
        expect(result).to eq('Not enough words in source text')
      end
    end

    context 'when no matching words found' do
      let(:source_text) { create(:source_text, content: 'cat bird fish tree flower dragon world magic star dream') }
      let(:options) { { spine_word: 'xyz' } }

      it 'returns error message when no words match' do
        expect(result).to eq('Could not generate mesostic poem with given spine word')
      end
    end

    context 'with partial matches' do
      let(:source_text) { create(:source_text, content: 'dog cat bird fish tree flower dragon world magic star dream') }
      let(:options) { { spine_word: 'dogx' } }

      it 'stops when no word matches the required letter position' do
        result = generator.send(:generate_mesostic, options)
        expect(result.lines.count).to eq(3)
      end
    end

    context 'with case insensitive matching' do
      let(:source_text) { create(:source_text, content: 'Dog Cat Bird Fish Tree Flower Dragon World Magic Star Dream') }
      let(:options) { { spine_word: 'DOG' } }

      it 'matches letters case insensitively' do
        expect(result).to be_a(String)
        expect(result.lines.count).to eq(3)
        lines = result.lines.map(&:strip)
        expect(lines[0]).to start_with('d')
      end
    end
  end

  describe '#find_word_with_letter_at_position' do
    let(:generator) { described_class.new(source_text) }
    let(:source_text) { create(:source_text, content: 'dog cat bird fish tree flower dragon world magic star dream') }
    let(:words) { generator.send(:extract_clean_words) }

    it 'finds word with correct letter at correct position' do
      result = generator.send(:find_word_with_letter_at_position, words, 'd', 0)
      expect(result).to eq('dog')
    end

    it 'finds word with letter at non-first position' do
      result = generator.send(:find_word_with_letter_at_position, words, 'o', 1)
      expect(result).to eq('dog')
    end

    it 'returns nil when no word matches' do
      result = generator.send(:find_word_with_letter_at_position, words, 'x', 0)
      expect(result).to be_nil
    end

    it 'returns nil when position is beyond word length' do
      result = generator.send(:find_word_with_letter_at_position, words, 'g', 5)
      expect(result).to be_nil
    end
  end

  describe 'word processing logic' do
    let(:generator) { described_class.new(source_text) }

    context 'text preprocessing' do
      let(:source_text) { create(:source_text, content: 'Hello, World! This is a test... 123 & some-text.') }

      it 'correctly processes text according to the algorithm' do
        processed_words = source_text.content.downcase
                                     .gsub(/[^\w\s]/, '')
                                     .split
                                     .reject { |word| word.length < 2 }
                                     .uniq

        expect(processed_words).to include('hello', 'world', 'this', 'test', 'sometext', 'is')
        expect(processed_words).not_to include('a')
        expect(processed_words).to include('123')
      end
    end
  end
end
