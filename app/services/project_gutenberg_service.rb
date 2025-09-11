require 'httparty'

class ProjectGutenbergService
  include HTTParty

  base_uri ENV.fetch('GUTENBERG_BASE_URL', 'https://www.gutenberg.org')
  default_timeout 30

  def initialize
    @base_url = ENV.fetch('GUTENBERG_BASE_URL', 'https://www.gutenberg.org')
  end

  def import_text(gutenberg_id)
    content = fetch_text_content(gutenberg_id)
    return SourceText.new unless content

    metadata = fetch_metadata(gutenberg_id)
    title = metadata ? metadata[:title] : extract_title_from_content(content, gutenberg_id)

    source_text = SourceText.new(
      title: title,
      content: content,
      gutenberg_id: gutenberg_id
    )

    source_text.save
    source_text
  end

  private

  def fetch_metadata(gutenberg_id)
    response = self.class.get("/ebooks/#{gutenberg_id}")

    return unless response.success?

    title_match = response.body.match(%r{<title>(.*?)</title>}i)
    title = title_match ? title_match[1].gsub(' | Project Gutenberg', '').strip : "Book ##{gutenberg_id}"

    { title: title }
  end

  def fetch_text_content(gutenberg_id)
    text_urls = [
      "/files/#{gutenberg_id}/#{gutenberg_id}-0.txt",
      "/files/#{gutenberg_id}/#{gutenberg_id}.txt",
      "/cache/epub/#{gutenberg_id}/pg#{gutenberg_id}.txt"
    ]

    text_urls.each do |url|
      response = self.class.get(url)
      return clean_text(response.body) if response.success? && response.body.present?
    end

    nil
  end

  def extract_title_from_content(content, gutenberg_id)
    title_patterns = [
      /Project Gutenberg's\s+(.+?)(?:\s+by\s+|\s+#|\s+$)/i,
      /Title:\s*(.+?)$/i,
      /^(.+?)\s+by\s+/i
    ]

    title_patterns.each do |pattern|
      match = content.match(pattern)
      next unless match && match[1].strip.length.positive?

      title = match[1].strip
      title = title.gsub(/\s*#\d+.*$/, '')
      return title if title.length.positive?
    end

    "Book ##{gutenberg_id}"
  end

  def clean_text(raw_text)
    text = raw_text.dup

    start_marker = text.index(/\*{3}\s*START OF.*?\*{3}/i)
    if start_marker
      text = text[start_marker..]
      text = text.sub(/\*{3}\s*START OF.*?\*{3}/i, '').strip
    end

    end_marker = text.index(/\*{3}\s*END OF.*?\*{3}/i)
    text = text[0...end_marker].strip if end_marker
    text = text.gsub(/\[[^\]]*\]/, '')
    text = text.delete('_')
    text.gsub(/\n{3,}/, "\n\n").strip
  end
end
