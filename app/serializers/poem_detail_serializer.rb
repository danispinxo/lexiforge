class PoemDetailSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :technique_used, :created_at, :author_name, :author_id, :author_type, :is_public

  belongs_to :source_text, serializer: SourceTextSerializer

  delegate :author_name, to: :object
end
