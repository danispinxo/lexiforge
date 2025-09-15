class LipogramGenerator < BaseGenerator
  protected

  def default_method
    'lipogram'
  end

  private

  def generate_lipogram(options = {})
    config = extract_lipogram_config(options)
    words = extract_clean_words

    validation_error = validate_minimum_words
    return validation_error if validation_error

    validation_error = validate_letters_to_omit(config[:letters_to_omit])
    return validation_error if validation_error

    filtered_words = filter_words_by_omitted_letters(words, config[:letters_to_omit])

    validation_error = validate_filtered_words(filtered_words, config[:num_words])
    return validation_error if validation_error

    lines = generate_lipogram_lines(filtered_words, config)
    lines.join("\n")
  end

  def extract_lipogram_config(options)
    defaults = PoemGenerationConstants::DEFAULTS[:lipogram]
    {
      num_words: options[:num_words] || defaults[:num_words],
      line_length: options[:line_length] || defaults[:line_length],
      letters_to_omit: options[:letters_to_omit] || defaults[:letter_to_omit]
    }
  end

  def validate_letters_to_omit(letters_to_omit)
    return 'Letter to omit is required' if letters_to_omit.blank?
    return 'Letter to omit must be exactly one letter' if letters_to_omit.length != 1
    return 'Letter to omit must be an alphabetic character' unless letters_to_omit.match?(/\A[a-zA-Z]\z/)

    nil
  end

  def validate_filtered_words(filtered_words, num_words)
    return 'Not enough words available after filtering by omitted letters' if filtered_words.length < num_words

    nil
  end

  def filter_words_by_omitted_letters(words, letters_to_omit)
    omitted_letters = letters_to_omit.downcase.chars
    words.reject do |word|
      word.downcase.chars.any? { |char| omitted_letters.include?(char) }
    end
  end

  def generate_lipogram_lines(filtered_words, config)
    lines = []
    word_range = random_range_for_length(config[:line_length])
    remaining_words = filtered_words.dup
    words_used = 0

    while words_used < config[:num_words] && !remaining_words.empty?
      line_length = calculate_line_length(word_range, config[:num_words] - words_used)
      line_words = select_words_for_line(remaining_words, line_length)

      break unless line_words.any?

      lines << line_words.join(' ').capitalize
      words_used += line_words.length
      remaining_words -= line_words

    end

    lines
  end

  def calculate_line_length(word_range, remaining_words)
    max_possible = [word_range.max, remaining_words].min
    min_possible = [word_range.min, remaining_words].min

    min_possible = [min_possible, word_range.min].max

    if min_possible == max_possible
      min_possible
    else
      rand(min_possible..max_possible)
    end
  end

  def select_words_for_line(available_words, line_length)
    return [] if available_words.empty? || line_length.nil? || line_length <= 0

    available_words.sample([line_length, available_words.length].min)
  end
end
