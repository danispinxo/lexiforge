class PoemDetailSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :technique_used, :created_at, :author_name

  belongs_to :source_text, serializer: SourceTextSerializer

  delegate :author_name, to: :object
end
