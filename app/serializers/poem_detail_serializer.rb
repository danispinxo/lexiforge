class PoemDetailSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :technique_used, :created_at
  
  belongs_to :source_text, serializer: SourceTextSerializer
end