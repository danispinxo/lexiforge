class AddGutenbergIdToSourceTexts < ActiveRecord::Migration[7.1]
  def change
    add_column :source_texts, :gutenberg_id, :integer
  end
end
