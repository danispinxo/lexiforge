class AddUniqueIndexToSourceTextsGutenbergId < ActiveRecord::Migration[7.1]
  def change
    add_index :source_texts, :gutenberg_id, unique: true
  end
end
