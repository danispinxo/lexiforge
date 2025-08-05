class SourceTextDetailSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :gutenberg_id, :word_count, :created_at, :poems_count
  
  def word_count
    object.content&.split&.length || 0
  end
  
  def poems_count
    object.poems.count
  end
end