class CreateDictionaryWords < ActiveRecord::Migration[7.0]
  def change
    create_table :dictionary_words do |t|
      t.string :word, null: false
      t.string :part_of_speech, null: false
      t.text :definition
      t.string :synsets, array: true, default: []
      
      t.timestamps
    end
    
    add_index :dictionary_words, :word
    add_index :dictionary_words, :part_of_speech
  end
end
