class SetDefaultPublicForExistingRecords < ActiveRecord::Migration[7.1]
  def up
    SourceText.where(is_public: nil).update_all(is_public: true)
    
    Poem.where(is_public: nil).update_all(is_public: true)
  end

  def down
    # No need to reverse this - we're just setting defaults for existing data
  end
end
