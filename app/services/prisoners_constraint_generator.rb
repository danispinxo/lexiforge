class PrisonersConstraintGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'prisoners_constraint'

    case method
    when 'prisoners_constraint'
      generate_prisoners_constraint(options)
    else
      raise "Invalid method: #{method}"
    end
  end

  private

  def generate_prisoners_constraint(options = {})
    config = extract_config(options)
    words = extract_clean_words
    filtered_words = filter_words_by_constraint(words, config[:constraint_type])

    return 'Not enough words in source text that meet the constraint' if filtered_words.length < config[:num_words]

    selected_words = filtered_words.sample(config[:num_words])
    lineate_words(selected_words)
  end

  def extract_config(options)
    {
      num_words: options[:num_words] || 20,
      constraint_type: options[:constraint_type] || 'full_constraint'
    }
  end

  def extract_clean_words
    @source_text.content.downcase
                .gsub(/[^\w\s]/, '')
                .split
                .reject { |word| word.match?(/[^a-z]/) }
                .uniq
  end

  def filter_words_by_constraint(words, constraint_type)
    case constraint_type
    when 'no_ascenders'
      filter_no_ascenders(words)
    when 'no_descenders'
      filter_no_descenders(words)
    when 'full_constraint'
      filter_full_constraint(words)
    else
      words
    end
  end

  def filter_no_ascenders(words)
    ascenders = %w[b d f h k l t]
    words.reject { |word| word.chars.any? { |char| ascenders.include?(char) } }
  end

  def filter_no_descenders(words)
    descenders = %w[g j p q y]
    words.reject { |word| word.chars.any? { |char| descenders.include?(char) } }
  end

  def filter_full_constraint(words)
    prohibited_letters = %w[b d f g h j k l p q t y]
    words.reject { |word| word.chars.any? { |char| prohibited_letters.include?(char) } }
  end

  def lineate_words(words)
    return words.join(' ') if words.length <= 3

    lines = []
    remaining_words = words.dup
    
    while remaining_words.any?
      line_length = case rand(100)
                    when 0..40 then 1 
                    when 41..70 then 2 
                    when 71..90 then 3 
                    else 4 
                    end
      
      line_length = [line_length, remaining_words.length].min
      
      line_words = remaining_words.shift(line_length)
      lines << line_words.join(' ')
    end
    
    lines.join("\n")
  end
end
