require 'rails_helper'

RSpec.describe AbecedarianGenerator, type: :service do
  let(:source_text) { create(:source_text, content: sample_content) }
  let(:sample_content) do
    'Apple trees grow tall. Beautiful birds sing sweetly. Cats climb carefully up trees. ' \
      'Dogs dance delightfully in gardens. Elephants eat enormous amounts of food. ' \
      'Fish fly through water quickly. Great green grass grows everywhere. ' \
      'Happy horses hop around fields. Iguanas ignore most interruptions completely. ' \
      'Joyful jumping jaguars play together. Kind kangaroos keep moving forward. ' \
      'Lions live in large groups. Mice move very quietly at night. ' \
      'Nice new nests need careful construction. Owls observe everything around them. ' \
      'Purple penguins prefer cold weather. Quiet quails question everything they see. ' \
      'Red roses require regular watering. Small snakes slither silently away. ' \
      'Tall trees tower over everything. Unique unicorns understand magical things. ' \
      'Very valuable violets bloom in spring. Wise wolves wander through forests. ' \
      'Excellent xylem carries water upward. Yellow yaks yell loudly sometimes. ' \
      'Zebras zoom around the savanna quickly.'
  end

  describe '#generate' do
    context 'with valid options' do
      let(:options) do
        {
          method: 'abecedarian',
          words_per_line: 5
        }
      end

      it 'generates an abecedarian poem with 26 lines' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        lines = result.split("\n", -1)
        expect(lines.length).to eq(26)
      end

      it 'follows alphabetical order' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        lines = result.split("\n", -1)
        alphabet = ('a'..'z').to_a

        lines.each_with_index do |line, index|
          next if line.empty?

          first_word = line.strip.split.first
          expected_letter = alphabet[index]

          expect(first_word.downcase[0]).to eq(expected_letter)
        end
      end

      it 'uses consecutive words from source text' do
        generator = described_class.new(source_text)
        result = generator.generate(options)

        lines = result.split("\n", -1).reject(&:empty?)
        expect(lines).not_to be_empty

        source_words = sample_content.downcase.gsub(/[^\w\s]/, '').split

        lines.each do |line|
          line_words = line.downcase.gsub(/[^\w\s]/, '').split
          next if line_words.empty?

          found_sequence = false
          (0..(source_words.length - line_words.length)).each do |i|
            if source_words[i, line_words.length] == line_words
              found_sequence = true
              break
            end
          end

          expect(found_sequence).to be(true), "Line '#{line}' should contain consecutive words from source text"
        end
      end

      it 'includes empty lines for missing letters' do
        limited_source = create(:source_text, content: 'Apple cat dog elephant')
        generator = described_class.new(limited_source)
        result = generator.generate(options)

        lines = result.split("\n", -1)
        expect(lines.length).to eq(26)

        empty_lines = lines.select(&:empty?)
        expect(empty_lines.length).to be > 0
      end

      it 'respects words_per_line parameter' do
        options[:words_per_line] = 3
        generator = described_class.new(source_text)
        result = generator.generate(options)

        non_empty_lines = result.split("\n").reject(&:empty?)
        non_empty_lines.each do |line|
          word_count = line.split.length
          expect(word_count).to be <= 3
        end
      end
    end

    context 'with different words_per_line values' do
      [1, 3, 5, 8].each do |word_count|
        it "generates poem with #{word_count} words per line" do
          options = {
            method: 'abecedarian',
            words_per_line: word_count
          }

          generator = described_class.new(source_text)
          result = generator.generate(options)

          lines = result.split("\n", -1)
          expect(lines.length).to eq(26)

          non_empty_lines = lines.reject(&:empty?)
          non_empty_lines.each do |line|
            expect(line.split.length).to be <= word_count
          end
        end
      end
    end

    context 'with insufficient content' do
      let(:short_source) { create(:source_text, content: 'A cat') }

      it 'still generates 26 lines with many empty lines' do
        options = {
          method: 'abecedarian',
          words_per_line: 5
        }

        generator = described_class.new(short_source)
        result = generator.generate(options)

        lines = result.split("\n", -1)
        expect(lines.length).to eq(26)

        empty_lines = lines.select(&:empty?)
        expect(empty_lines.length).to be > 20
      end
    end

    context 'with overlapping word positions' do
      it 'avoids reusing the same word positions' do
        generator = described_class.new(source_text)
        result = generator.generate({ method: 'abecedarian', words_per_line: 3 })

        lines = result.split("\n", -1).reject(&:empty?)
        used_sequences = []

        lines.each do |line|
          line_words = line.downcase.gsub(/[^\w\s]/, '').split
          used_sequences << line_words
        end

        expect(used_sequences.uniq.length).to eq(used_sequences.length)
      end
    end
  end

  describe '#default_method' do
    it 'returns abecedarian' do
      generator = described_class.new(source_text)
      expect(generator.send(:default_method)).to eq('abecedarian')
    end
  end
end
