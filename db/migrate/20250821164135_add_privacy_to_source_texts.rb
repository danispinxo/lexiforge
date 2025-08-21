class AddPrivacyToSourceTexts < ActiveRecord::Migration[7.1]
  def change
    add_column :source_texts, :is_public, :boolean, default: true, null: false
    add_reference :source_texts, :user, null: true, foreign_key: true
  end
end
