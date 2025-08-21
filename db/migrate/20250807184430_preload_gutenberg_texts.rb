class PreloadGutenbergTexts < ActiveRecord::Migration[7.1]
  def up
    gutenberg_ids = [2383, 16328, 1727, 1322, 4099, 26, 36098]
    
    gutenberg_ids.each do |gutenberg_id|
      next if connection.exec_query("SELECT 1 FROM source_texts WHERE gutenberg_id = #{gutenberg_id}").any?
      
      service = ProjectGutenbergService.new
      source_text = service.import_text(gutenberg_id)
      
      source_text.save(validate: false) if source_text && source_text.new_record?
    end
  end

  def down
    gutenberg_ids = [2383, 16328, 1727, 1322, 4099, 26, 36098]
    SourceText.where(gutenberg_id: gutenberg_ids).destroy_all
  end
end
