namespace :gutenberg do
  desc "Preload classic texts from Project Gutenberg"
  task preload: :environment do
    gutenberg_ids = [2383, 16328, 1727, 1322, 4099, 26, 36098]
    
    puts "Starting Project Gutenberg preload..."
    
    gutenberg_ids.each do |gutenberg_id|
      if SourceText.exists?(gutenberg_id: gutenberg_id)
        puts "Skipping Gutenberg text #{gutenberg_id} (already exists)"
        next
      end
      
      print "Importing Gutenberg text #{gutenberg_id}... "
      
      service = ProjectGutenbergService.new
      source_text = service.import_text(gutenberg_id)
      
      if source_text.persisted?
        puts "✓ #{source_text.title}"
      else
        puts "✗ Failed: #{source_text.errors.full_messages.join(', ')}"
      end
    end
    
    puts "\nPreload complete! #{SourceText.from_gutenberg.count} Gutenberg texts loaded."
  end
  
  desc "Remove all preloaded Gutenberg texts"
  task clean: :environment do
    gutenberg_ids = [2383, 16328, 1727, 1322, 4099, 26, 36098]
    
    puts "Removing preloaded Gutenberg texts..."
    
    removed_count = SourceText.where(gutenberg_id: gutenberg_ids).destroy_all.count
    
    puts "Removed #{removed_count} Gutenberg texts."
  end
  
  desc "List all Gutenberg texts with their status"
  task status: :environment do
    gutenberg_ids = [2383, 16328, 1727, 1322, 4099, 26, 36098]
    
    puts "Gutenberg Text Status:"
    puts "====================="
    
    gutenberg_ids.each do |gutenberg_id|
      source_text = SourceText.find_by(gutenberg_id: gutenberg_id)
      
      if source_text
        status = "✓ Loaded"
        title = source_text.title
        poems_count = source_text.poems.count
        poems_info = poems_count > 0 ? " (#{poems_count} poems generated)" : ""
      else
        status = "✗ Missing"
        title = "Unknown"
        poems_info = ""
      end
      
      puts "#{gutenberg_id.to_s.rjust(5)}: #{status.ljust(10)} #{title}#{poems_info}"
    end
    
    total_loaded = SourceText.where(gutenberg_id: gutenberg_ids).count
    puts "\nTotal: #{total_loaded}/#{gutenberg_ids.length} texts loaded"
  end
end
