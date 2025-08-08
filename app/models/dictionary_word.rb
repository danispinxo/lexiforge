class DictionaryWord < ApplicationRecord
  validates :word, presence: true, uniqueness: { scope: [:part_of_speech] }
  validates :part_of_speech, presence: true

  scope :nouns, -> { where(part_of_speech: 'n') }
  scope :by_id, ->(id) { where(id: id) }

  def self.find_n_plus_seven(word, offset = 7)
    word_record = find_by(word: word.downcase)
    return nil unless word_record

    target_id = word_record.id + offset
    search_range = 50

    replacement = find_by(id: target_id, part_of_speech: word_record.part_of_speech)
    return replacement if replacement

    start_id = [target_id - search_range, 1].max
    end_id = target_id + search_range

    where(part_of_speech: word_record.part_of_speech)
      .where('id BETWEEN ? AND ?', start_id, end_id)
      .order(Arel.sql("ABS(id - #{target_id})"))
      .first
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at definition id id_value part_of_speech synsets updated_at word]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
