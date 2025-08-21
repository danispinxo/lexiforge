class AddPrivacyToPoems < ActiveRecord::Migration[7.1]
  def change
    add_column :poems, :is_public, :boolean, default: true, null: false
  end
end
