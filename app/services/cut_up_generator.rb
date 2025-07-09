class CutUpGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'lines'
    size = options[:size] || 'medium'
    
    case method
    when 'lines'
      generate_line_cutup(size)
    when 'sentences'
      generate_sentence_cutup(size)
    when 'paragraphs'
      generate_paragraph_cutup(size)
    else
      generate_line_cutup(size)
    end
  end

  private

  def generate_line_cutup(size)
    # Split into lines and clean up
    lines = @source_text.content.split("\n")
                       .reject(&:blank?)
                       .reject { |line| line.strip.length < 10 } # Skip very short lines
                       .map(&:strip)

    # Select a random sample based on size
    sample_size = case size
                  when 'small' then 8..15
                  when 'medium' then 15..25  
                  when 'large' then 25..40
                  else 15..25
                  end

    # Take a random sample
    selected_lines = lines.sample(rand(sample_size))
    
    # Shuffle and join
    selected_lines.shuffle.join("\n")
  end

  def generate_sentence_cutup(size)
    # Split into sentences
    sentences = @source_text.content.split(/[.!?]+/)
                            .map(&:strip)
                            .reject(&:blank?)
                            .reject { |s| s.length < 20 } # Skip very short sentences

    sample_size = case size
                  when 'small' then 6..12
                  when 'medium' then 10..18
                  when 'large' then 15..25
                  else 10..18
                  end

    selected_sentences = sentences.sample(rand(sample_size))
    
    # Join with periods and add some line breaks for poetry format
    result = selected_sentences.shuffle.map(&:strip).join(".\n")
    
    # Add final period if not present
    result += "." unless result.end_with?(".")
    
    # Add some stanza breaks (every 3-4 lines)
    lines = result.split("\n")
    formatted_lines = []
    
    lines.each_with_index do |line, index|
      formatted_lines << line
      # Add stanza break every 3-4 lines
      if (index + 1) % [3, 4].sample == 0 && index < lines.length - 1
        formatted_lines << ""
      end
    end
    
    formatted_lines.join("\n")
  end

  def generate_paragraph_cutup(size)
    # Split into paragraphs
    paragraphs = @source_text.content.split(/\n\s*\n/)
                             .map(&:strip)
                             .reject(&:blank?)
                             .reject { |p| p.length < 50 } # Skip very short paragraphs

    sample_size = case size
                  when 'small' then 2..4
                  when 'medium' then 3..6
                  when 'large' then 5..8
                  else 3..6
                  end

    selected_paragraphs = paragraphs.sample(rand(sample_size))
    
    # Shuffle paragraphs and join with double line breaks
    selected_paragraphs.shuffle.join("\n\n")
  end
end