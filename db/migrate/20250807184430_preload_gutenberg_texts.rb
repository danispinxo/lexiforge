class PreloadGutenbergTexts < ActiveRecord::Migration[7.1]
  def up
    gutenberg_ids = [2383, 16328, 1727, 1322, 4099, 26, 36098]
    service = ProjectGutenbergService.new
    
    gutenberg_ids.each do |gutenberg_id|
      next if SourceText.exists?(gutenberg_id: gutenberg_id)
      
      service.import_text(gutenberg_id)
    end
  end

  def down
    gutenberg_ids = [2383, 16328, 1727, 1322, 4099, 26, 36098]
    SourceText.where(gutenberg_id: gutenberg_ids).destroy_all
  end
end
