class PreloadGutenbergTexts < ActiveRecord::Migration[7.1]
  def up
    gutenberg_ids = [2383, 16328, 1727, 1322, 4099, 26, 36098]
    
    gutenberg_ids.each do |gutenberg_id|
      next if SourceText.exists?(gutenberg_id: gutenberg_id)
      
      service = ProjectGutenbergService.new
      source_text = service.import_text(gutenberg_id)
      
      if source_text.persisted?
        puts "Successfully imported Gutenberg text #{gutenberg_id}: #{source_text.title}"
      else
        puts "Failed to import Gutenberg text #{gutenberg_id}: #{source_text.errors.full_messages.join(', ')}"
      end
    end
  end

  def down
    gutenberg_ids = [2383, 16328, 1727, 1322, 4099, 26, 36098]
    SourceText.where(gutenberg_id: gutenberg_ids).destroy_all
  end
end
