class PoemSerializer < ActiveModel::Serializer
  attributes :id, :title, :technique_used, :content_preview, :created_at
  
  belongs_to :source_text, serializer: SourceTextSerializer
  
  def content_preview
    object.content&.truncate(200) || ''
  end
end