require 'httparty'

class ProjectGutenbergService
  include HTTParty

  base_uri 'https://www.gutenberg.org'

  def initialize
    @base_url = 'https://www.gutenberg.org'
  end

  def search_books(query, _limit = 10)
    # Search for books using the Project Gutenberg search API
    response = self.class.get("/ebooks/search/?query=#{URI.encode_www_form_component(query)}&format=json")

    if response.success?
      # NOTE: Project Gutenberg doesn't have a direct JSON search API
      # This is a placeholder - we'll implement a different approach
      []
    else
      []
    end
  end

  def import_text(gutenberg_id)
    # Fetch metadata first
    metadata = fetch_metadata(gutenberg_id)
    return SourceText.new unless metadata

    # Fetch the plain text content
    content = fetch_text_content(gutenberg_id)
    return SourceText.new unless content

    # Create and save the source text
    source_text = SourceText.new(
      title: metadata[:title],
      content: content,
      gutenberg_id: gutenberg_id
    )

    source_text.save
    source_text
  end

  def fetch_popular_books
    # Return some popular classic literature IDs
    [
      { id: 1342, title: 'Pride and Prejudice by Jane Austen' },
      { id: 11, title: "Alice's Adventures in Wonderland by Lewis Carroll" },
      { id: 74, title: 'The Adventures of Tom Sawyer by Mark Twain' },
      { id: 1661, title: 'The Adventures of Sherlock Holmes by Arthur Conan Doyle' },
      { id: 2701, title: 'Moby Dick; Or, The Whale by Herman Melville' },
      { id: 1260, title: 'Jane Eyre by Charlotte Brontë' },
      { id: 25_344, title: 'The Scarlet Letter by Nathaniel Hawthorne' },
      { id: 98, title: 'A Tale of Two Cities by Charles Dickens' },
      { id: 844, title: 'The Importance of Being Earnest by Oscar Wilde' },
      { id: 16_328, title: 'Beowulf: An Anglo-Saxon Epic Poem' }
    ]
  end

  private

  def fetch_metadata(gutenberg_id)
    # Try to fetch basic metadata - Project Gutenberg doesn't have a full metadata API
    # So we'll extract it from the HTML page
    response = self.class.get("/ebooks/#{gutenberg_id}")

    return unless response.success?

    # Parse title from HTML (simplified)
    title_match = response.body.match(%r{<title>(.*?)</title>}i)
    title = title_match ? title_match[1].gsub(' | Project Gutenberg', '').strip : "Book ##{gutenberg_id}"

    { title: title }
  end

  def fetch_text_content(gutenberg_id)
    # Try different text format URLs in order of preference
    text_urls = [
      "/files/#{gutenberg_id}/#{gutenberg_id}-0.txt",  # UTF-8
      "/files/#{gutenberg_id}/#{gutenberg_id}.txt",    # ASCII
      "/cache/epub/#{gutenberg_id}/pg#{gutenberg_id}.txt" # Alternative format
    ]

    text_urls.each do |url|
      response = self.class.get(url)
      return clean_text(response.body) if response.success? && response.body.present?
    end

    nil
  end

  def clean_text(raw_text)
    # Remove Project Gutenberg header and footer
    text = raw_text.dup

    # Remove header (everything before "*** START OF")
    start_marker = text.index(/\*{3}\s*START OF.*?\*{3}/i)
    if start_marker
      text = text[start_marker..-1]
      text = text.sub(/\*{3}\s*START OF.*?\*{3}/i, '').strip
    end

    # Remove footer (everything after "*** END OF")
    end_marker = text.index(/\*{3}\s*END OF.*?\*{3}/i)
    text = text[0...end_marker].strip if end_marker

    # Clean up extra whitespace
    text.gsub(/\n{3,}/, "\n\n").strip
  end
end
