require 'set'

class SnowballGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'snowball'

    case method
    when 'snowball'
      generate_snowball(options)
    else
      raise "Invalid method: #{method}"
    end
  end

  private

  def generate_snowball(options = {})
    num_lines = options[:num_lines] || 10
    min_word_length = options[:min_word_length] || 1
    
    words = extract_clean_words(@source_text.content, min_word_length)

    return 'Not enough words in source text' if words.length < 10

    words_by_length = words.group_by(&:length)
    available_lengths = words_by_length.keys.sort
    
    return 'Not enough word variety for snowball poem' if available_lengths.length < 3

    lines = []
    current_length = min_word_length
    used_words = Set.new
    
    num_lines.times do
      available_words = (words_by_length[current_length] || []).reject { |word| used_words.include?(word) }
      
      if available_words.empty?
        lines << ""
        current_length += 1
        next
      end
      
      selected_word = available_words.sample
      lines << selected_word
      used_words.add(selected_word)
      
      current_length += 1
    end

    return 'Could not generate enough lines for snowball poem' if lines.length < 3

    lines.join("\n")
  end

  def extract_clean_words(content, min_length)
    content.downcase    
           .gsub(/[^\w\s'-]/, ' ') 
           .split(/\s+/)
           .reject { |word| word.empty? || word.length < min_length }
           .select { |word| word.match?(/\A[a-z'-]+\z/) }
           .uniq
  end

end