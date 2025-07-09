class CreatePoems < ActiveRecord::Migration[7.1]
  def change
    create_table :poems do |t|
      t.string :title
      t.text :content
      t.string :technique_used
      t.references :source_text, null: false, foreign_key: true

      t.timestamps
    end
  end
end
