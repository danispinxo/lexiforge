class ErasureGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'erasure'

    case method
    when 'erasure'
      generate_erasure(options)
    else
      raise "Invalid method: #{method}"
    end
  end

  private

  def generate_erasure(options = {})
    num_pages = options[:num_pages] || 3
    words_per_page = options[:words_per_page] || 50
    words_to_keep = options[:words_to_keep] || 8
    is_blackout = options[:is_blackout] || false

    original_text = @source_text.content.strip
    
    return 'Not enough content in source text' if original_text.length < 100

    pages = []
    
    num_pages.times do |page_num|
      max_start = [original_text.length - (words_per_page * 8), 0].max
      start_pos = rand(max_start + 1)
      
      start_pos = find_word_boundary(original_text, start_pos, :start)
      
      excerpt = extract_text_excerpt(original_text, start_pos, words_per_page)
      next if excerpt.strip.empty?
      
      erased_page = create_prose_erasure(excerpt, words_to_keep, is_blackout)
      pages << erased_page
    end

    # Format pages for frontend display
    result = {
      type: 'erasure_pages',
      is_blackout: is_blackout,
      pages: pages.map.with_index(1) do |page, index|
        {
          number: index,
          content: page
        }
      end
    }.to_json

    result
  end

  def find_word_boundary(text, pos, direction)
    return 0 if pos <= 0
    return text.length if pos >= text.length
    
    if direction == :start
      while pos > 0 && text[pos] !~ /\s/
        pos -= 1
      end
      while pos < text.length && text[pos] =~ /\s/
        pos += 1
      end
    end
    
    pos
  end

  def extract_text_excerpt(text, start_pos, target_word_count)
    excerpt = ""
    word_count = 0
    pos = start_pos
    
    while pos < text.length && word_count < target_word_count
      char = text[pos]
      excerpt += char
      
      if pos == text.length - 1 || (char !~ /\s/ && pos + 1 < text.length && text[pos + 1] =~ /\s/)
        word_count += 1
      end
      
      pos += 1
    end
    
    excerpt
  end

  def create_prose_erasure(text, words_to_keep, is_blackout = false)
    words_with_spacing = extract_words_with_spacing(text)
    
    return text if words_with_spacing.length < 2
    
    total_words = words_with_spacing.count { |item| item[:type] == :word }
    words_to_keep_actual = [words_to_keep, total_words].min
    
    word_indices = []
    words_with_spacing.each_with_index do |item, index|
      word_indices << index if item[:type] == :word
    end
    
    keep_indices = word_indices.sample(words_to_keep_actual)
    
    result = ""
    words_with_spacing.each_with_index do |item, index|
      if item[:type] == :space
        result += item[:text]
      elsif keep_indices.include?(index)
        result += item[:text]
      else
        if is_blackout
          result += "<span class='blackout-word'>#{'█' * item[:text].length}</span>"
        else
          result += " " * item[:text].length
        end
      end
    end
    
    result
  end

  def extract_words_with_spacing(text)
    result = []
    current_word = ""
    current_space = ""
    
    text.each_char do |char|
      if char =~ /\s/
        if !current_word.empty?
          result << { type: :word, text: current_word }
          current_word = ""
        end
        current_space += char
      else
        if !current_space.empty?
          result << { type: :space, text: current_space }
          current_space = ""
        end
        current_word += char
      end
    end
    
    result << { type: :word, text: current_word } if !current_word.empty?
    result << { type: :space, text: current_space } if !current_space.empty?
    
    result
  end
end