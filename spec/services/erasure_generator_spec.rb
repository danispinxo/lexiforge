require 'rails_helper'

RSpec.describe ErasureGenerator do
  let(:source_text) { create(:source_text, :long_content) }
  let(:generator) { described_class.new(source_text) }

  describe '#initialize' do
    it 'accepts a source text' do
      expect(generator.instance_variable_get(:@source_text)).to eq(source_text)
    end
  end

  describe '#generate' do
    context 'with default method' do
      it 'calls generate_erasure by default' do
        expect(generator).to receive(:generate_erasure).with({})
        generator.generate
      end
    end

    context 'with erasure method' do
      it 'calls generate_erasure' do
        expect(generator).to receive(:generate_erasure).with({ method: 'erasure' })
        generator.generate(method: 'erasure')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid') }.to raise_error('Invalid method: invalid')
      end
    end
  end

  describe '#generate_erasure' do
    let(:result) { generator.send(:generate_erasure, options) }
    let(:parsed_result) { JSON.parse(result) }

    context 'with default options' do
      let(:options) { {} }

      it 'generates erasure pages' do
        expect(parsed_result['type']).to eq('erasure_pages')
        expect(parsed_result['is_blackout']).to be false
        expect(parsed_result['pages']).to be_an(Array)
        expect(parsed_result['pages'].length).to eq(3)
      end

      it 'creates pages with correct structure' do
        page = parsed_result['pages'].first
        expect(page).to have_key('number')
        expect(page).to have_key('content')
        expect(page['number']).to be_a(Integer)
        expect(page['content']).to be_a(String)
      end
    end

    context 'with custom options' do
      let(:options) { { num_pages: 2, words_per_page: 30, words_to_keep: 5, is_blackout: true } }

      it 'respects custom options' do
        expect(parsed_result['pages'].length).to eq(2)
        expect(parsed_result['is_blackout']).to be true
      end
    end

    context 'with short source text' do
      let(:source_text) { create(:source_text, :short_content) }
      let(:options) { {} }

      it 'returns error message for insufficient content' do
        expect(result).to eq('Not enough content in source text')
      end
    end

    context 'with empty content' do
      let(:source_text) do
        text = build(:source_text, content: '')
        text.save(validate: false)
        text
      end
      let(:options) { {} }

      it 'returns error message for empty content' do
        expect(result).to eq('Not enough content in source text')
      end
    end
  end

  describe '#find_word_boundary' do
    let(:text) { 'Hello world this is a test' }

    context 'finding start boundary' do
      it 'finds word start from middle of word' do
        result = generator.send(:find_word_boundary, text, 8, :start)
        expect(result).to eq(6)
      end

      it 'returns 0 for position at beginning' do
        result = generator.send(:find_word_boundary, text, 0, :start)
        expect(result).to eq(0)
      end

      it 'handles position beyond text length' do
        result = generator.send(:find_word_boundary, text, 100, :start)
        expect(result).to eq(text.length)
      end

      it 'handles negative position' do
        result = generator.send(:find_word_boundary, text, -5, :start)
        expect(result).to eq(0)
      end
    end
  end

  describe '#extract_text_excerpt' do
    let(:text) { 'One two three four five six seven eight nine ten' }

    it 'extracts the correct number of words' do
      result = generator.send(:extract_text_excerpt, text, 0, 3)
      expect(result).to eq('One two three')
    end

    it 'handles starting position in middle of text' do
      result = generator.send(:extract_text_excerpt, text, 8, 2)
      expect(result).to eq('three four')
    end

    it 'handles case where there are fewer words than requested' do
      result = generator.send(:extract_text_excerpt, text, 40, 10)
      expect(result.split.length).to be <= 10
    end

    it 'returns empty string for position beyond text' do
      result = generator.send(:extract_text_excerpt, text, 100, 5)
      expect(result).to eq('')
    end
  end

  describe '#create_prose_erasure' do
    let(:text) { 'Hello world this is a test' }

    context 'normal erasure' do
      let(:result) { generator.send(:create_prose_erasure, text, words_to_keep: 2, is_blackout: false) }

      it 'keeps approximately the requested number of words' do

        kept_words = result.split.reject { |word| word.strip.empty? }
        expect(kept_words.length).to eq(2)
      end

      it 'preserves word spacing with spaces' do
        expect(result).to match(/\s+/)
        expect(result).not_to include('█')
      end
    end

    context 'blackout erasure' do
      let(:result) { generator.send(:create_prose_erasure, text, words_to_keep: 2, is_blackout: true) }

      it 'uses blackout spans for removed words' do
        expect(result).to include("<span class='blackout-word'>")
        expect(result).to include('█')
      end

      it 'keeps the requested number of visible words' do

        visible_text = result.gsub(/<[^>]*>/, '').gsub(/█+/, '')
        visible_words = visible_text.split.reject { |word| word.strip.empty? }
        expect(visible_words.length).to eq(2)
      end
    end

    context 'with very short text' do
      let(:short_text) { 'Hi' }
      let(:result) { generator.send(:create_prose_erasure, short_text, words_to_keep: 5, is_blackout: false) }

      it 'returns original text when too few words' do
        expect(result).to eq(short_text)
      end
    end

    context 'when keeping more words than available' do
      let(:result) { generator.send(:create_prose_erasure, text, words_to_keep: 20, is_blackout: false) }

      it 'keeps all words when requested count exceeds available' do
        word_count = text.split.length
        kept_words = result.split.reject { |word| word.strip.empty? }
        expect(kept_words.length).to eq(word_count)
      end
    end
  end

  describe '#extract_words_with_spacing' do
    let(:text) { "Hello  world\tthis\nis  a   test" }
    let(:result) { generator.send(:extract_words_with_spacing, text) }

    it 'correctly identifies words and spaces' do
      word_items = result.select { |item| item[:type] == :word }
      space_items = result.select { |item| item[:type] == :space }

      expect(word_items.map { |item| item[:text] }).to eq(%w[Hello world this is a test])
      expect(space_items.length).to be > 0
    end

    it 'preserves exact spacing' do
      space_items = result.select { |item| item[:type] == :space }
      expect(space_items.first[:text]).to eq('  ')
    end

    it 'handles different whitespace characters' do
      space_texts = result.select { |item| item[:type] == :space }.map { |item| item[:text] }
      expect(space_texts.join).to include("\t")
      expect(space_texts.join).to include("\n")
    end

    it 'maintains correct order of elements' do
      reconstructed = result.map { |item| item[:text] }.join
      expect(reconstructed).to eq(text)
    end

    context 'with text ending in space' do
      let(:text) { 'hello world   ' }

      it 'includes trailing spaces' do
        last_item = result.last
        expect(last_item[:type]).to eq(:space)
        expect(last_item[:text]).to eq('   ')
      end
    end

    context 'with text ending in word' do
      let(:text) { 'hello world' }

      it 'includes final word' do
        last_item = result.last
        expect(last_item[:type]).to eq(:word)
        expect(last_item[:text]).to eq('world')
      end
    end
  end
end
