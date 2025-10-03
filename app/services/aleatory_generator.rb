class AleatoryGenerator < BaseGenerator
  protected

  def default_method
    'aleatory'
  end

  private

  def generate_aleatory(options = {})
    config = extract_aleatory_config(options)
    words = extract_clean_words

    validation_error = validate_minimum_words
    return validation_error if validation_error

    lines = generate_aleatory_lines(words, config)
    lines.join("\n")
  end

  def extract_aleatory_config(options)
    defaults = PoemGenerationConstants::DEFAULTS[:aleatory]
    {
      num_lines: options[:num_lines] || defaults[:num_lines],
      line_length: options[:line_length] || defaults[:line_length],
      randomness_factor: options[:randomness_factor] || defaults[:randomness_factor]
    }
  end

  def generate_aleatory_lines(words, config)
    lines = []
    word_range = calculate_word_range(config[:line_length])
    used_words = Set.new

    config[:num_lines].times do
      line = generate_random_line(words, word_range, used_words, config[:randomness_factor])
      lines << line if line
    end

    lines.compact
  end

  def generate_random_line(words, word_range, used_words, randomness_factor)
    line_length = rand(word_range)
    available_words = words.reject { |word| used_words.include?(word) }

    return nil if available_words.length < line_length

    if randomness_factor > 0.5
      selected_words = available_words.sample(line_length)
    else
      recent_words = used_words.to_a.last(10)
      preferred_words = available_words.reject { |word| recent_words.include?(word) }

      selected_words = if preferred_words.length >= line_length
                         preferred_words.sample(line_length)
                       else
                         available_words.sample(line_length)
                       end
    end

    selected_words.each { |word| used_words.add(word) }
    selected_words.join(' ').capitalize
  end

  def calculate_word_range(line_length)
    case line_length
    when 'very_short'
      PoemGenerationConstants::WORD_RANGES[:very_short]
    when 'short'
      PoemGenerationConstants::WORD_RANGES[:short]
    when 'long'
      PoemGenerationConstants::WORD_RANGES[:long]
    when 'very_long'
      PoemGenerationConstants::WORD_RANGES[:very_long]
    else
      PoemGenerationConstants::WORD_RANGES[:medium]
    end
  end
end
