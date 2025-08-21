class SetDefaultPublicForExistingSourceTexts < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      UPDATE source_texts 
      SET is_public = true 
      WHERE is_public IS NULL
    SQL
    
    execute <<-SQL
      UPDATE poems 
      SET is_public = true 
      WHERE is_public IS NULL
    SQL
  end

  def down
    execute <<-SQL
      UPDATE source_texts 
      SET is_public = NULL 
      WHERE is_public = true
    SQL
    
    execute <<-SQL
      UPDATE poems 
      SET is_public = NULL 
      WHERE is_public = true
    SQL
  end
end
