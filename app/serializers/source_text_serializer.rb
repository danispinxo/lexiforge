class SourceTextSerializer < ActiveModel::Serializer
  attributes :id, :title, :content_preview, :gutenberg_id, :word_count, :created_at, :is_public, :poems_count
  
  belongs_to :owner, polymorphic: true

  def content_preview
    object.content&.truncate(200) || ''
  end

  def word_count
    object.content&.split&.length || 0
  end

  def poems_count
    object.poems.count
  end
end
