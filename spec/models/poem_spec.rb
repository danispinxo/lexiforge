require 'rails_helper'

RSpec.describe Poem, type: :model do
  let(:source_text) { create(:source_text) }
  let(:poem) { create(:poem, source_text: source_text) }

  describe 'associations' do
    it { should belong_to(:source_text) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:technique_used) }

    it 'validates technique_used inclusion' do
      should validate_inclusion_of(:technique_used)
        .in_array(Poem::ALLOWED_TECHNIQUES)
        .with_message(/is not a valid technique/)
    end

    context 'with valid technique' do
      Poem::ALLOWED_TECHNIQUES.each do |technique|
        it "allows #{technique} as technique_used" do
          poem = build(:poem, technique_used: technique)
          expect(poem).to be_valid
        end
      end
    end

    context 'with invalid technique' do
      it 'rejects invalid technique' do
        poem = build(:poem, technique_used: 'invalid_technique')
        expect(poem).not_to be_valid
        expect(poem.errors[:technique_used]).to include(/is not a valid technique/)
      end
    end
  end

  describe 'scopes' do
    let!(:cutup_poem) { create(:poem, :cut_up_poem, source_text: source_text) }
    let!(:erasure_poem) { create(:poem, :erasure_poem, source_text: source_text) }
    let!(:old_poem) { create(:poem, source_text: source_text, created_at: 1.week.ago) }
    let!(:recent_poem) { create(:poem, source_text: source_text, created_at: 1.hour.ago) }

    describe '.cut_up_poems' do
      it 'returns only cutup poems' do
        expect(Poem.cut_up_poems).to include(cutup_poem)
        expect(Poem.cut_up_poems).not_to include(erasure_poem)
      end
    end

    describe '.recent' do
      it 'orders poems by creation date descending' do
        recent_poems = Poem.recent.limit(10) # Limit to avoid interference from other tests
        poems_created_in_test = [old_poem, recent_poem, cutup_poem, erasure_poem]
        poems_created_in_test.sort_by(&:created_at).reverse

        expect(recent_poems.first.created_at).to be >= recent_poems.last.created_at
      end
    end
  end

  describe 'instance methods' do
    describe '#word_count' do
      it 'returns the number of words in content' do
        poem = create(:poem, content: 'This is a test poem with six words')
        expect(poem.word_count).to eq(8)
      end

      it 'handles empty content' do
        poem = build(:poem, content: '')
        poem.save(validate: false)
        expect(poem.word_count).to eq(0)
      end

      it 'handles content with multiple spaces' do
        poem = create(:poem, content: 'word1    word2     word3')
        expect(poem.word_count).to eq(3)
      end

      it 'handles content with newlines' do
        poem = create(:poem, content: "line one\nline two\nline three")
        expect(poem.word_count).to eq(6)
      end
    end

    describe '#line_count' do
      it 'returns the number of lines in content' do
        poem = create(:poem, content: "Line 1\nLine 2\nLine 3")
        expect(poem.line_count).to eq(3)
      end

      it 'returns 1 for single line content' do
        poem = create(:poem, content: 'Single line')
        expect(poem.line_count).to eq(1)
      end

      it 'handles empty content' do
        poem = build(:poem, content: '')
        poem.save(validate: false)
        expect(poem.line_count).to eq(0) # Empty string has 0 lines
      end

      it 'handles content with trailing newline' do
        poem = create(:poem, content: "Line 1\nLine 2\n")
        expect(poem.line_count).to eq(2)
      end
    end

    describe '#created_date' do
      it 'returns formatted creation date' do
        travel_to Time.zone.local(2023, 12, 25, 14, 30, 0) do
          poem = create(:poem)
          expect(poem.created_date).to eq('December 25, 2023 at  2:30 PM')
        end
      end
    end

    describe '#short_content' do
      context 'with default limit' do
        it 'returns full content when under limit' do
          poem = create(:poem, content: 'Short content')
          expect(poem.short_content).to eq('Short content')
        end

        it 'truncates content when over limit' do
          long_content = 'word ' * 50 # More than 100 characters
          poem = create(:poem, content: long_content)
          short = poem.short_content

          expect(short.length).to be <= 100
          expect(short).to end_with('...')
        end

        it 'truncates at word boundaries' do
          # Create content that would be truncated mid-word without separator
          long_content = "#{'word ' * 30}verylongwordthatwouldbecutoff"
          poem = create(:poem, content: long_content)
          short = poem.short_content

          expect(short).not_to include('verylongwordthatwouldbecutoff')
        end
      end

      context 'with custom limit' do
        it 'respects custom limit' do
          poem = create(:poem, content: 'This is a longer content string for testing')
          short = poem.short_content(20)

          expect(short.length).to be <= 20
        end

        it 'returns full content when under custom limit' do
          poem = create(:poem, content: 'Short')
          expect(poem.short_content(50)).to eq('Short')
        end
      end
    end
  end

  describe 'constants' do
    describe 'ALLOWED_TECHNIQUES' do
      it 'includes expected techniques' do
        expected_techniques = ['cutup', 'erasure', 'blackout', 'n+7', 'definitional', 'snowball', 'mesostic']
        expect(Poem::ALLOWED_TECHNIQUES).to eq(expected_techniques)
      end

      it 'is frozen' do
        expect(Poem::ALLOWED_TECHNIQUES).to be_frozen
      end
    end
  end
end
