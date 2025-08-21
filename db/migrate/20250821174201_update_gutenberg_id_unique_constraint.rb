class UpdateGutenbergIdUniqueConstraint < ActiveRecord::Migration[7.1]
  def up
    # Remove the existing unique index
    remove_index :source_texts, :gutenberg_id
    
    # Add a partial unique index that only applies to public texts
    add_index :source_texts, :gutenberg_id, 
              unique: true, 
              where: "is_public = true AND gutenberg_id IS NOT NULL",
              name: "index_source_texts_on_gutenberg_id_public_unique"
  end

  def down
    # Remove the partial unique index
    remove_index :source_texts, name: "index_source_texts_on_gutenberg_id_public_unique"
    
    # Add back the original unique index
    add_index :source_texts, :gutenberg_id, unique: true
  end
end
