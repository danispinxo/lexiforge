require 'rails_helper'

RSpec.describe KwicGenerator do
  let(:source_text) { create(:source_text, content: sample_content) }
  let(:generator) { described_class.new(source_text) }

  let(:sample_content) do
    'The wind whispers through the tall trees in the forest. ' \
      'A strong wind howled all night long during the storm. ' \
      'She felt the gentle wind on her face as she walked. ' \
      'The wind carried the scent of rain across the valley. ' \
      'When the wind died down at dawn, silence filled the air. ' \
      'Birds dance in the wind above the meadow. ' \
      'The wind instruments played a beautiful melody. ' \
      'Without wind, the sailboat remained motionless. ' \
      'The autumn wind scattered colorful leaves everywhere. ' \
      'A cool wind brought relief from the summer heat.'
  end

  describe '#generate' do
    context 'with valid keyword' do
      it 'generates a KWIC poem with the keyword "wind"' do
        result = generator.generate(keyword: 'wind')
        lines = result.split("\n")

        expect(lines.length).to be >= 1
        expect(lines.length).to be <= 10

        lines.each do |line|
          expect(line.downcase).to include('wind')
        end
      end

      it 'respects the num_lines parameter' do
        result = generator.generate(keyword: 'wind', num_lines: 5)
        lines = result.split("\n")

        expect(lines.length).to be <= 5
      end

      it 'uses the context_window parameter' do
        result = generator.generate(keyword: 'wind', context_window: 2)
        lines = result.split("\n")

        lines.each do |line|
          words = line.split
          expect(words.length).to be <= 5
        end
      end

      it 'capitalizes the first letter of each line' do
        result = generator.generate(keyword: 'wind')
        lines = result.split("\n")

        lines.each do |line|
          expect(line).to match(/^[A-Z]/)
        end
      end
    end

    context 'with different context windows' do
      it 'generates narrow context with window size 1' do
        result = generator.generate(keyword: 'wind', context_window: 1)
        lines = result.split("\n")

        lines.each do |line|
          words = line.split
          expect(words.length).to be <= 3
        end
      end

      it 'generates wide context with window size 5' do
        result = generator.generate(keyword: 'wind', context_window: 5)
        lines = result.split("\n")

        lines.each do |line|
          words = line.split
          expect(words.length).to be <= 11
        end
      end
    end

    context 'with different keywords' do
      it 'finds contexts for the keyword "the"' do
        result = generator.generate(keyword: 'the')
        lines = result.split("\n")

        expect(lines.length).to be >= 1
        lines.each do |line|
          expect(line.downcase).to include('the')
        end
      end

      it 'handles case-insensitive keyword matching' do
        result = generator.generate(keyword: 'WIND')
        lines = result.split("\n")

        expect(lines.length).to be >= 1
        lines.each do |line|
          expect(line.downcase).to include('wind')
        end
      end
    end

    context 'with keyword not found' do
      it 'returns an appropriate error message' do
        result = generator.generate(keyword: 'nonexistent')
        expect(result).to eq("Keyword 'nonexistent' not found in source text. Try a different word.")
      end
    end

    context 'with missing keyword' do
      it 'returns an error message when keyword is nil' do
        result = generator.generate(keyword: nil)
        expect(result).to eq('Keyword is required for KWIC generation')
      end

      it 'returns an error message when keyword is empty' do
        result = generator.generate(keyword: '')
        expect(result).to eq('Keyword is required for KWIC generation')
      end

      it 'returns an error message when keyword is whitespace' do
        result = generator.generate(keyword: '   ')
        expect(result).to eq('Keyword is required for KWIC generation')
      end
    end

    context 'with insufficient content' do
      let(:source_text) { create(:source_text, content: 'Too short') }

      it 'returns an error message' do
        result = generator.generate(keyword: 'short')
        expect(result).to eq('Not enough sentences in source text')
      end
    end

    context 'with invalid method' do
      it 'raises an error' do
        expect { generator.generate(method: 'invalid', keyword: 'wind') }.to raise_error('Invalid method: invalid')
      end
    end

    context 'with default parameters' do
      it 'uses default values when options are not provided' do
        result = generator.generate(keyword: 'wind')
        lines = result.split("\n")

        expect(lines.length).to be <= 10
        lines.each do |line|
          words = line.split
          expect(words.length).to be <= 7
        end
      end
    end

    context 'line uniqueness' do
      it 'removes duplicate lines' do
        duplicate_content = 'The wind blows strongly today and tomorrow. The wind blows strongly today and tomorrow. The wind blows strongly today and tomorrow.'
        source_text_with_duplicates = create(:source_text, content: duplicate_content)
        generator_with_duplicates = described_class.new(source_text_with_duplicates)
        
        result = generator_with_duplicates.generate(keyword: 'wind')
        lines = result.split("\n")
        
        unique_lines = lines.uniq
        expect(lines.length).to eq(unique_lines.length)
      end
    end

    context 'edge cases' do
      it 'handles keyword at the beginning of a sentence' do
        content_with_start_keyword = 'Wind is everywhere in the world today and tomorrow. The air moves with strong wind power and renewable energy sources.'
        source_with_start = create(:source_text, content: content_with_start_keyword)
        generator_with_start = described_class.new(source_with_start)
        
        result = generator_with_start.generate(keyword: 'wind')
        lines = result.split("\n")
        
        expect(lines.length).to be >= 1
        lines.each do |line|
          expect(line.downcase).to include('wind')
        end
      end

      it 'handles keyword at the end of a sentence' do
        content_with_end_keyword = 'The power and energy comes from beautiful renewable wind. She loves the strong and powerful natural wind.'
        source_with_end = create(:source_text, content: content_with_end_keyword)
        generator_with_end = described_class.new(source_with_end)
        
        result = generator_with_end.generate(keyword: 'wind')
        lines = result.split("\n")
        
        expect(lines.length).to be >= 1
        lines.each do |line|
          expect(line.downcase).to include('wind')
        end
      end

      it 'handles very short sentences' do
        short_content = 'Wind blows strongly today and tomorrow morning. Strong wind moves quickly through the trees. The wind feels good on your face.'
        source_short = create(:source_text, content: short_content)
        generator_short = described_class.new(source_short)
        
        result = generator_short.generate(keyword: 'wind')
        lines = result.split("\n")
        
        expect(lines.length).to be >= 1
        lines.each do |line|
          expect(line.downcase).to include('wind')
        end
      end
    end
  end
end
