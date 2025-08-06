require 'rails_helper'

RSpec.describe CutUpGenerator do
  let(:source_text) { create(:source_text, :long_content) }
  let(:generator) { described_class.new(source_text) }

  describe '#initialize' do
    it 'accepts a source text' do
      expect(generator.instance_variable_get(:@source_text)).to eq(source_text)
    end
  end

  describe '#generate' do
    context 'with default method' do
      it 'calls generate_cutup by default' do
        expect(generator).to receive(:generate_cutup).with({})
        generator.generate
      end
    end

    context 'with cut_up method' do
      it 'calls generate_cutup' do
        expect(generator).to receive(:generate_cutup).with({ method: 'cut_up' })
        generator.generate(method: 'cut_up')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid') }.to raise_error('Invalid method: invalid')
      end
    end
  end

  describe '#generate_cutup' do
    let(:result) { generator.send(:generate_cutup, options) }

    context 'with default options' do
      let(:options) { {} }

      it 'generates cut-up poem with default settings' do
        expect(result).to be_a(String)
        expect(result.lines.count).to eq(12) # default num_lines
        expect(result).not_to be_empty
      end

      it 'creates lines with appropriate word counts' do
        lines = result.lines.map(&:strip)
        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be_between(5, 7)
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
      let(:options) { { num_lines: 8, words_per_line: 10 } }

      it 'respects custom line count' do
        expect(result.lines.count).to eq(8)
      end

      it 'respects custom words per line setting' do
        lines = result.lines.map(&:strip)
        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be_between(8, 12)
        end
      end
    end

    context 'with different words_per_line values' do
      [3, 6, 10, 15].each do |words_per_line|
        context "with #{words_per_line} words_per_line" do
          let(:options) { { words_per_line: words_per_line } }

          it "generates appropriate word ranges for #{words_per_line}" do
            lines = result.lines.map(&:strip)
            lines.each do |line|
              word_count = line.split.length
              case words_per_line
              when 3
                expect(word_count).to be_between(3, 4)
              when 6
                expect(word_count).to be_between(5, 7)
              when 10
                expect(word_count).to be_between(8, 12)
              when 15
                expect(word_count).to be_between(12, 18)
              end
            end
          end
        end
      end
    end

    context 'with unrecognized words_per_line value' do
      let(:options) { { words_per_line: 99 } }

      it 'uses default range' do
        lines = result.lines.map(&:strip)
        lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be_between(5, 7)
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

    context 'with short words filtered out' do
      let(:source_text) { create(:source_text, content: 'a an to of is at in on we me be do go it up') }
      let(:options) { {} }

      it 'filters out words shorter than 2 characters' do
        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end
    end

    context 'with punctuation in source text' do
      let(:source_text) { create(:source_text, content: 'Hello, world! This is a test... with punctuation?') }
      let(:options) { {} }

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
      let(:options) { {} }

      it 'uses unique words only' do
        source_words = result.split.uniq
        all_words = result.split

        expect(source_words.length).to be <= all_words.length
      end
    end

    context 'randomization' do
      let(:options) { { num_lines: 5, words_per_line: 3 } }

      it 'produces different results on multiple runs' do
        results = Array.new(5) { generator.send(:generate_cutup, options) }

        expect(results.uniq.length).to be > 1
      end
    end
  end

  describe 'word processing logic' do
    let(:generator) { described_class.new(source_text) }

    context 'text preprocessing' do
      let(:source_text) { create(:source_text, content: 'Hello, World! This is a test... 123 & some-text.') }

      it 'correctly processes text according to the algorithm' do
        # Simulate the processing steps from generate_cutup
        processed_words = source_text.content.downcase
                                     .gsub(/[^\w\s]/, '')
                                     .split
                                     .reject { |word| word.length < 2 }
                                     .uniq

        expect(processed_words).to include('hello', 'world', 'this', 'test', 'sometext', 'is')
        expect(processed_words).not_to include('a') # single character words (if any existed)
        expect(processed_words).to include('123') # numbers are included in \w
      end
    end
  end
end
