class DictionaryWord < ApplicationRecord
  validates :word, presence: true, uniqueness: { scope: [:part_of_speech] }
  validates :part_of_speech, presence: true
  
  scope :nouns, -> { where(part_of_speech: 'noun') }
  scope :by_id, ->(id) { where(id: id) }
  
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "definition", "id", "id_value", "part_of_speech", "synsets", "updated_at", "word"]
  end
end
