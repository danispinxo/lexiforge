class ConvertSourceTextUserToPolymorphic < ActiveRecord::Migration[7.1]
  def up
    add_column :source_texts, :owner_type, :string
    add_column :source_texts, :owner_id, :bigint
    
    execute <<-SQL
      UPDATE source_texts 
      SET owner_type = 'User', owner_id = user_id 
      WHERE user_id IS NOT NULL
    SQL
    
    add_index :source_texts, [:owner_type, :owner_id]
    
    remove_foreign_key :source_texts, :users
    remove_column :source_texts, :user_id
  end

  def down
    add_reference :source_texts, :user, null: true, foreign_key: true
    
    execute <<-SQL
      UPDATE source_texts 
      SET user_id = owner_id 
      WHERE owner_type = 'User'
    SQL
    
    remove_index :source_texts, [:owner_type, :owner_id]
    remove_column :source_texts, :owner_type
    remove_column :source_texts, :owner_id
  end
end
