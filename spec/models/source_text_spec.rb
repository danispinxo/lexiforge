require 'rails_helper'

RSpec.describe SourceText, type: :model do
  let(:source_text) { create(:source_text) }

  describe 'associations' do
    it { should have_many(:poems).dependent(:destroy) }

    it 'destroys associated poems when source text is deleted' do
      create(:poem, source_text: source_text)
      expect { source_text.destroy }.to change(Poem, :count).by(-1)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }

    context 'gutenberg_id uniqueness' do
      it 'allows multiple source texts with nil gutenberg_id' do
        create(:source_text, gutenberg_id: nil)
        source_text2 = build(:source_text, gutenberg_id: nil)

        expect(source_text2).to be_valid
      end

      it 'prevents duplicate gutenberg_ids for public source texts' do
        create(:source_text, gutenberg_id: 98_765, is_public: true)
        duplicate = build(:source_text, gutenberg_id: 98_765, is_public: true)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:gutenberg_id]).to include('already exists as a public source text')
      end

      it 'allows duplicate gutenberg_ids for private source texts' do
        create(:source_text, gutenberg_id: 98_766, is_public: false)
        duplicate = build(:source_text, gutenberg_id: 98_766, is_public: false)

        expect(duplicate).to be_valid
      end

      it 'allows same gutenberg_id for one public and one private source text' do
        create(:source_text, gutenberg_id: 98_767, is_public: true)
        private_text = build(:source_text, gutenberg_id: 98_767, is_public: false)

        expect(private_text).to be_valid
      end

      it 'allows different gutenberg_ids' do
        create(:source_text, gutenberg_id: 98_768)
        different = build(:source_text, gutenberg_id: 98_769)

        expect(different).to be_valid
      end
    end

    context 'privacy attributes' do
      it 'defaults to public when is_public is not specified' do
        source_text = create(:source_text)
        expect(source_text.is_public).to eq(true)
      end

      it 'can be set as private' do
        private_text = create(:source_text, is_public: false)
        expect(private_text.is_public).to eq(false)
      end

      it 'can be set as public' do
        public_text = create(:source_text, is_public: true)
        expect(public_text.is_public).to eq(true)
      end
    end
  end

  describe 'scopes' do
    let!(:gutenberg_text) { create(:source_text, :with_gutenberg_id) }
    let!(:custom_text) { create(:source_text, gutenberg_id: nil) }
    let!(:public_text) { create(:source_text, is_public: true) }
    let!(:private_text) { create(:source_text, is_public: false) }

    describe '.from_gutenberg' do
      it 'returns only source texts with gutenberg_id' do
        gutenberg_texts = SourceText.from_gutenberg

        expect(gutenberg_texts).to include(gutenberg_text)
        expect(gutenberg_texts).not_to include(custom_text)
      end

      it 'excludes source texts with nil gutenberg_id' do
        expect(SourceText.from_gutenberg.where(gutenberg_id: nil)).to be_empty
      end
    end

    describe '.custom' do
      it 'returns only source texts without gutenberg_id' do
        custom_texts = SourceText.custom

        expect(custom_texts).to include(custom_text)
        expect(custom_texts).not_to include(gutenberg_text)
      end

      it 'includes only source texts with nil gutenberg_id' do
        expect(SourceText.custom.where.not(gutenberg_id: nil)).to be_empty
      end
    end

    describe '.public_texts' do
      it 'returns only public source texts' do
        public_texts = SourceText.public_texts

        expect(public_texts).to include(public_text)
        expect(public_texts).not_to include(private_text)
      end

      it 'excludes private source texts' do
        expect(SourceText.public_texts.where(is_public: false)).to be_empty
      end
    end

    describe '.private_texts' do
      it 'returns only private source texts' do
        private_texts = SourceText.private_texts

        expect(private_texts).to include(private_text)
        expect(private_texts).not_to include(public_text)
      end

      it 'excludes public source texts' do
        expect(SourceText.private_texts.where(is_public: true)).to be_empty
      end
    end

    describe '.for_owner' do
      let(:user) { create(:user) }
      let(:admin) { create(:admin_user) }
      let!(:user_text) { create(:source_text, owner: user) }
      let!(:admin_text) { create(:source_text, owner: admin) }
      let!(:unowned_text) { create(:source_text, owner: nil) }

      it 'returns source texts for specific user' do
        user_texts = SourceText.for_owner(user)

        expect(user_texts).to include(user_text)
        expect(user_texts).not_to include(admin_text)
        expect(user_texts).not_to include(unowned_text)
      end

      it 'returns source texts for specific admin' do
        admin_texts = SourceText.for_owner(admin)

        expect(admin_texts).to include(admin_text)
        expect(admin_texts).not_to include(user_text)
        expect(admin_texts).not_to include(unowned_text)
      end
    end
  end

  describe 'instance behavior' do
    describe 'poem association' do
      it 'can have multiple poems' do
        poem1 = create(:poem, source_text: source_text)
        poem2 = create(:poem, source_text: source_text)

        expect(source_text.poems).to include(poem1, poem2)
        expect(source_text.poems.count).to eq(2)
      end

      it 'starts with no poems' do
        new_source_text = create(:source_text)
        expect(new_source_text.poems).to be_empty
      end
    end

    describe 'content handling' do
      it 'accepts long content' do
        long_text = create(:source_text, :long_content)
        expect(long_text).to be_valid
        expect(long_text.content.length).to be > 500
      end

      it 'handles empty content as invalid' do
        empty_text = build(:source_text, :empty_content)
        expect(empty_text).not_to be_valid
      end

      it 'preserves exact content including formatting' do
        formatted_content = "Line 1\n\nLine 3 with   spaces\tand\ttabs"
        formatted_text = create(:source_text, content: formatted_content)

        expect(formatted_text.content).to eq(formatted_content)
      end
    end

    describe 'gutenberg integration' do
      it 'can store gutenberg metadata' do
        gutenberg_text = create(:source_text, :with_gutenberg_id, gutenberg_id: 12_345)

        expect(gutenberg_text.gutenberg_id).to eq(12_345)
        expect(gutenberg_text).to be_valid
      end

      it 'handles custom texts without gutenberg_id' do
        custom_text = create(:source_text, gutenberg_id: nil)

        expect(custom_text.gutenberg_id).to be_nil
        expect(custom_text).to be_valid
      end
    end
  end

  describe 'factory traits' do
    describe ':with_gutenberg_id' do
      it 'creates source text with gutenberg_id' do
        gutenberg_text = create(:source_text, :with_gutenberg_id)
        expect(gutenberg_text.gutenberg_id).not_to be_nil
      end
    end

    describe ':short_content' do
      it 'creates source text with short content' do
        short_text = create(:source_text, :short_content)
        expect(short_text.content.length).to be < 50
      end
    end

    describe ':long_content' do
      it 'creates source text with long content' do
        long_text = create(:source_text, :long_content)
        expect(long_text.content.length).to be > 500
      end
    end

    describe ':empty_content' do
      it 'creates source text with empty content (invalid)' do
        empty_text = build(:source_text, :empty_content)
        expect(empty_text.content).to be_empty
        expect(empty_text).not_to be_valid
      end
    end
  end

  describe 'edge cases' do
    it 'handles very large gutenberg_id values' do
      large_id_text = create(:source_text, gutenberg_id: 999_999_999)
      expect(large_id_text).to be_valid
      expect(large_id_text.gutenberg_id).to eq(999_999_999)
    end

    it 'handles titles with special characters' do
      special_title = "Title with émojis 🎭 and spëcial chars!@\#$%"
      special_text = create(:source_text, title: special_title)

      expect(special_text).to be_valid
      expect(special_text.title).to eq(special_title)
    end

    it 'handles content with unicode characters' do
      unicode_content = 'Content with émojis 🌟 and unicode: café, naïve, résumé'
      unicode_text = create(:source_text, content: unicode_content)

      expect(unicode_text).to be_valid
      expect(unicode_text.content).to eq(unicode_content)
    end

    it 'handles very long titles' do
      long_title = 'A' * 1000
      long_title_text = create(:source_text, title: long_title)

      expect(long_title_text).to be_valid
      expect(long_title_text.title).to eq(long_title)
    end
  end
end
