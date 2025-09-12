class PoemSerializer < ActiveModel::Serializer
  attributes :id, :title, :technique_used, :content_preview, :created_at, :author_name, :author_id, :author_type, :is_public

  belongs_to :source_text, serializer: SourceTextSerializer

  def content_preview
    object.content&.truncate(200) || ''
  end

  delegate :author_name, to: :object
end
