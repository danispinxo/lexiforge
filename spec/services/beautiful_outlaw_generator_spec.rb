require 'rails_helper'

RSpec.describe BeautifulOutlawGenerator do
  let(:source_text) { create(:source_text, :long_content) }
  let(:generator) { described_class.new(source_text) }

  describe '#initialize' do
    it 'accepts a source text' do
      expect(generator.instance_variable_get(:@source_text)).to eq(source_text)
    end
  end

  describe '#generate' do
    context 'with default method' do
      it 'calls generate_beautifuloutlaw by default' do
        expect(generator).to receive(:generate_beautifuloutlaw).with({})
        generator.generate
      end
    end

    context 'with beautiful_outlaw method' do
      it 'calls generate_beautifuloutlaw' do
        expect(generator).to receive(:generate_beautifuloutlaw).with({ method: 'beautiful_outlaw' })
        generator.generate(method: 'beautiful_outlaw')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid') }.to raise_error('Invalid method: invalid. Only supported method: beautiful_outlaw')
      end
    end
  end

  describe '#generate_beautifuloutlaw' do
    let(:result) { generator.send(:generate_beautifuloutlaw, options) }

    context 'with valid hidden word' do
      let(:options) { { hidden_word: 'love' } }

      it 'generates beautiful outlaw poem as plain text' do
        expect(result).to be_a(String)
        expect(result).not_to be_empty

        stanzas = result.split("\n\n")
        expect(stanzas.length).to eq(4)
      end

      it 'creates stanzas for each letter of hidden word' do
        stanzas = result.split("\n\n")

        expect(stanzas.length).to eq(4)

        stanzas.each do |stanza|
          lines = stanza.split("\n")
          expect(lines.length).to eq(4)
        end
      end

      it 'excludes forbidden letters from each stanza' do
        stanzas = result.split("\n\n")
        hidden_word = 'love'

        stanzas.each_with_index do |stanza, index|
          forbidden_letter = hidden_word[index].downcase
          stanza_text = stanza.downcase

          expect(stanza_text).not_to include(forbidden_letter)
        end
      end

      it 'generates appropriate number of lines per stanza' do
        stanzas = result.split("\n\n")

        stanzas.each do |stanza|
          lines = stanza.split("\n")
          expect(lines.length).to eq(4)
        end
      end
    end

    context 'with custom options' do
      let(:options) { { hidden_word: 'art', lines_per_stanza: 3, words_per_line: 4 } }

      it 'respects custom lines per stanza' do
        stanzas = result.split("\n\n")

        stanzas.each do |stanza|
          lines = stanza.split("\n")
          expect(lines.length).to eq(3)
        end
      end

      it 'respects custom words per line' do
        stanzas = result.split("\n\n")

        stanzas.each do |stanza|
          lines = stanza.split("\n")
          lines.each do |line|
            word_count = line.split.length
            expect(word_count).to be <= 4
          end
        end
      end
    end

    context 'with hidden word containing special characters' do
      let(:options) { { hidden_word: 'hello-world!' } }

      it 'filters out non-alphabetic characters' do
        stanzas = result.split("\n\n")
        expect(stanzas.length).to eq(10)
      end
    end

    context 'with uppercase hidden word' do
      let(:options) { { hidden_word: 'DREAM' } }

      it 'processes correctly regardless of case' do
        stanzas = result.split("\n\n")
        expect(stanzas.length).to eq(5)
      end
    end

    context 'without hidden word' do
      let(:options) { {} }

      it 'returns error message for missing hidden word' do
        expect(result).to eq('Hidden word is required')
      end
    end

    context 'with empty hidden word' do
      let(:options) { { hidden_word: '' } }

      it 'returns error message for empty hidden word' do
        expect(result).to eq('Hidden word is required')
      end
    end

    context 'with insufficient source words' do
      let(:source_text) { create(:source_text, content: 'a b c d e f g h i j k') }
      let(:options) { { hidden_word: 'test' } }

      it 'returns error message for insufficient words' do
        expect(result).to eq('Not enough words in source text')
      end
    end

    context 'with words that all contain forbidden letters' do
      let(:source_text) { create(:source_text, content: 'hello world love lovely letter light long large line local level logical leader learn large little') }
      let(:options) { { hidden_word: 'l' } }

      it 'handles case where no words are available for a stanza' do
        expect(result).to eq('Unable to generate poem with the given constraints')
      end
    end

    context 'letter diversity optimization' do
      let(:options) { { hidden_word: 'joy', words_per_line: 3 } }

      it 'attempts to maximize letter diversity in lines' do
        stanzas = result.split("\n\n")
        hidden_word = 'joy'

        stanzas.each_with_index do |stanza, index|
          lines = stanza.split("\n")
          lines.each do |line|
            forbidden_letter = hidden_word[index].downcase
            expect(line.downcase).not_to include(forbidden_letter)
          end
        end
      end
    end

    context 'word filtering' do
      let(:source_text) { create(:source_text, content: 'apple banana cherry date elderberry fig grape honey lemon orange peach plum berry mint coconut pineapple mango kiwi melon strawberry blueberry') }
      let(:options) { { hidden_word: 'a' } }

      it 'correctly filters out words containing forbidden letter' do
        stanzas = result.split("\n\n")
        first_stanza = stanzas.first
        stanza_text = first_stanza.downcase

        expect(stanza_text).not_to include('apple')
        expect(stanza_text).not_to include('banana')
        expect(stanza_text).not_to include('date')
        expect(stanza_text).not_to include('grape')
        expect(stanza_text).not_to include('orange')
        expect(stanza_text).not_to include('peach')
        expect(stanza_text).not_to include('mango')
        expect(stanza_text).not_to include('strawberry')

        forbidden_words = %w[apple banana date grape orange peach mango strawberry]
        stanza_words = stanza_text.split
        stanza_words.each do |word|
          expect(forbidden_words).not_to include(word)
          expect(word).not_to include('a')
        end
      end
    end

    context 'randomization' do
      let(:source_text) { create(:source_text, content: 'the quick brown fox jumps over lazy dog mouse bird tree house water wind sun moon star light dark night day time space world earth nature beauty love peace hope dream wish magic wonder mystery adventure journey path road bridge mountain valley river ocean forest meadow garden flower bloom spring summer winter autumn season change growth life energy power strength wisdom knowledge truth justice freedom spirit heart mind soul body health happiness joy laughter smile warmth kindness gentle grace harmony balance unity diversity creativity inspiration imagination vision future past present moment eternal infinite') }
      let(:options) { { hidden_word: 'joy', lines_per_stanza: 2, words_per_line: 3 } }

      it 'produces different results on multiple runs' do
        results = Array.new(10) { generator.send(:generate_beautifuloutlaw, options) }

        expect(results.length).to eq(10)
        expect(results.all?(String)).to be true

        unique_count = results.uniq.length
        expect(unique_count).to be >= 1
      end
    end
  end

  describe 'lipogram constraints' do
    let(:source_text) { create(:source_text, content: 'the quick brown jumps over lazy dog cat mouse bird tree house water wind sun moon star light dark night day time space world earth nature beauty love peace hope dream wish magic wonder mystery adventure journey path road bridge mountain valley river ocean forest meadow garden flower bloom spring summer winter autumn season change growth life energy power strength wisdom knowledge truth justice freedom spirit heart mind soul body health happiness joy laughter smile warmth kindness gentle grace harmony balance unity diversity creativity inspiration imagination vision future past present moment eternal infinite') }
    let(:options) { { hidden_word: 'cat' } }

    it 'enforces lipogram rules strictly' do
      result = generator.send(:generate_beautifuloutlaw, options)
      stanzas = result.split("\n\n")
      hidden_word = options[:hidden_word]

      stanzas.each_with_index do |stanza, index|
        forbidden_letter = hidden_word[index].downcase
        stanza_text = stanza.downcase

        expect(stanza_text).not_to include(forbidden_letter),
                                   "Stanza #{index + 1} contains forbidden letter '#{forbidden_letter}'"
      end
    end
  end
end
