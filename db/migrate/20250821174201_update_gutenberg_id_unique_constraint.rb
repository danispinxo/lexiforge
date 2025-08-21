class UpdateGutenbergIdUniqueConstraint < ActiveRecord::Migration[7.1]
  def up
    remove_index :source_texts, :gutenberg_id
    add_index :source_texts, :gutenberg_id, 
              unique: true, 
              where: "is_public = true AND gutenberg_id IS NOT NULL",
              name: "index_source_texts_on_gutenberg_id_public_unique"
  end

  def down
    remove_index :source_texts, name: "index_source_texts_on_gutenberg_id_public_unique"
    
    add_index :source_texts, :gutenberg_id, unique: true
  end
end
