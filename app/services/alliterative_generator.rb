require 'set'

class AlliterativeGenerator < BaseGenerator
  protected

  def default_method
    'alliterative'
  end

  private

  def generate_alliterative(options = {})
    config = extract_alliterative_config(options)
    words = extract_clean_words

    validation_error = validate_minimum_words
    return validation_error if validation_error

    validation_error = validate_alliteration_letter(config[:alliteration_letter])
    return validation_error if validation_error

    filtered_words = filter_words_by_alliteration(words, config[:alliteration_letter])

    word_range = calculate_word_range(config[:line_length])
    min_words_per_line = word_range.min

    validation_error = validate_filtered_words(filtered_words, min_words_per_line)
    return validation_error if validation_error

    lines = generate_alliterative_lines(filtered_words, config)
    lines.join("\n")
  end

  def extract_alliterative_config(options)
    defaults = PoemGenerationConstants::DEFAULTS[:alliterative]
    {
      num_lines: options[:num_lines] || defaults[:num_lines],
      line_length: options[:line_length] || defaults[:line_length],
      alliteration_letter: options[:alliteration_letter] || defaults[:alliteration_letter]
    }
  end

  def validate_alliteration_letter(alliteration_letter)
    return 'Alliteration letter is required' if alliteration_letter.blank?
    return 'Alliteration letter must be a single letter' unless alliteration_letter.length == 1
    return 'Alliteration letter must be alphabetic' unless alliteration_letter.match?(/\A[a-zA-Z]\z/)

    nil
  end

  def validate_filtered_words(filtered_words, num_words)
    return 'Not enough words available that start with the specified letter' if filtered_words.length < num_words

    nil
  end

  def filter_words_by_alliteration(words, alliteration_letter)
    target_letter = alliteration_letter.downcase
    words.select { |word| word.downcase.start_with?(target_letter) }
  end

  def generate_alliterative_lines(filtered_words, config)
    lines = []
    word_range = calculate_word_range(config[:line_length])

    config[:num_lines].times do
      line_length = rand(word_range)
      line_words = filtered_words.sample(line_length)
      lines << line_words.join(' ').capitalize
    end

    lines
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
