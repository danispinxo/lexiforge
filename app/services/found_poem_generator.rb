class FoundPoemGenerator < BaseGenerator
  protected

  def default_method
    'found'
  end

  private

  def generate_found(options = {})
    config = extract_found_poem_config(options)
    words = extract_clean_words

    validation_error = validate_minimum_words(PoemGenerationConstants::VALIDATION[:minimum_found_poem_words])
    return validation_error if validation_error

    lines = generate_found_poem_lines(words, config)
    lines.join("\n")
  end

  def extract_found_poem_config(options)
    defaults = PoemGenerationConstants::DEFAULTS[:found]
    {
      num_lines: options[:num_lines] || defaults[:num_lines],
      line_length: options[:line_length] || defaults[:line_length]
    }
  end

  def generate_found_poem_lines(words, config)
    lines = []
    word_range = calculate_word_range(config[:line_length])
    section_size = calculate_section_size(words, config[:num_lines])

    config[:num_lines].times do |i|
      line = generate_single_line(words, word_range, section_size, i)
      lines << line if line
    end

    lines.compact
  end

  def calculate_section_size(words, num_lines)
    words.length / num_lines
  end

  def generate_single_line(words, word_range, section_size, line_index)
    start_pos = calculate_line_start_position(words, word_range, section_size, line_index)
    line_length = rand(word_range)
    line_words = words[start_pos, line_length]

    if valid_line_words?(line_words, word_range)
      line_words.join(' ').capitalize
    else
      find_fallback_line(words, word_range)
    end
  end

  def calculate_line_start_position(words, word_range, section_size, line_index)
    section_start = (line_index * section_size) % (words.length - word_range.max)
    section_end = [section_start + section_size, words.length - word_range.max].min

    if section_end > section_start
      rand(section_start..section_end)
    else
      rand(words.length - word_range.max)
    end
  end

  def valid_line_words?(line_words, word_range)
    line_words && line_words.length >= word_range.min
  end

  def calculate_word_range(line_length)
    random_range_for_length(line_length)
  end

  def find_fallback_line(words, word_range)
    return nil if words.length < word_range.min

    fallback_line = find_random_valid_line(words, word_range)
    return fallback_line if fallback_line

    create_last_resort_line(words, word_range)
  end

  def find_random_valid_line(words, word_range)
    max_attempts = PoemGenerationConstants::FOUND_POEM[:max_fallback_attempts]
    attempts = 0

    while attempts < max_attempts
      start_pos = rand(words.length - word_range.min)
      line_length = rand(word_range)

      if start_pos + line_length <= words.length
        line_words = words[start_pos, line_length]
        return line_words.join(' ').capitalize if line_words.length >= word_range.min
      end

      attempts += 1
    end

    nil
  end

  def create_last_resort_line(words, word_range)
    start_pos = rand([words.length - word_range.min, 0].max)
    line_words = words[start_pos, word_range.min]
    line_words&.join(' ')&.capitalize
  end
end
