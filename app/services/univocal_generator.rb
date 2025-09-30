require 'set'

class UnivocalGenerator < BaseGenerator
  protected

  def default_method
    'univocal'
  end

  private

  def generate_univocal(options = {})
    config = extract_univocal_config(options)
    words = extract_clean_words

    validation_error = validate_minimum_words
    return validation_error if validation_error

    validation_error = validate_vowel_to_use(config[:vowel_to_use])
    return validation_error if validation_error

    filtered_words = filter_words_by_single_vowel(words, config[:vowel_to_use])

    validation_error = validate_filtered_words(filtered_words, config[:num_words])
    return validation_error if validation_error

    lines = generate_univocal_lines(filtered_words, config)
    lines.join("\n")
  end

  def extract_univocal_config(options)
    defaults = PoemGenerationConstants::DEFAULTS[:univocal]
    {
      num_words: options[:num_words] || defaults[:num_words],
      line_length: options[:line_length] || defaults[:line_length],
      vowel_to_use: options[:vowel_to_use] || defaults[:vowel_to_use]
    }
  end

  def validate_vowel_to_use(vowel_to_use)
    return 'Vowel to use is required' if vowel_to_use.blank?
    return 'Vowel to use must be a single vowel (a, e, i, o, u)' unless %w[a e i o u].include?(vowel_to_use.downcase)

    nil
  end

  def validate_filtered_words(filtered_words, num_words)
    return 'Not enough words available that contain only the specified vowel' if filtered_words.length < num_words

    nil
  end

  def filter_words_by_single_vowel(words, vowel_to_use)
    target_vowel = vowel_to_use.downcase
    vowels = %w[a e i o u]
    other_vowels = vowels - [target_vowel]

    words.select do |word|
      word_chars = word.downcase.chars
      word_chars.any?(target_vowel) &&
        word_chars.none? { |char| other_vowels.include?(char) }
    end
  end

  def generate_univocal_lines(filtered_words, config)
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
