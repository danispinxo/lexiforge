require 'set'

class SnowballGenerator < BaseGenerator
  protected

  def default_method
    'snowball'
  end

  private

  def generate_snowball(options = {})
    defaults = PoemGenerationConstants::DEFAULTS[:snowball]
    num_lines = options[:num_lines] || defaults[:num_lines]
    min_word_length = options[:min_word_length] || defaults[:min_word_length]

    words = extract_clean_words_for_snowball(@source_text.content, min_word_length)

    validation_error = validate_words_for_snowball(words)
    return validation_error if validation_error

    words_by_length = words.group_by(&:length)
    lines = build_snowball_lines(words_by_length, num_lines, min_word_length)

    if lines.length < PoemGenerationConstants::VALIDATION[:minimum_snowball_lines]
      return 'Could not generate enough lines for snowball poem'
    end

    lines.join("\n")
  end

  def validate_words_for_snowball(words)
    return 'Not enough words in source text' if words.length < PoemGenerationConstants::VALIDATION[:minimum_words]

    words_by_length = words.group_by(&:length)
    available_lengths = words_by_length.keys.sort

    if available_lengths.length < PoemGenerationConstants::VALIDATION[:minimum_word_variety]
      return 'Not enough word variety for snowball poem'
    end

    nil
  end

  def build_snowball_lines(words_by_length, num_lines, min_word_length)
    lines = []
    current_length = min_word_length
    used_words = Set.new

    num_lines.times do
      word = select_word_for_length(words_by_length[current_length], used_words)

      if word
        lines << word
        used_words.add(word)
      else
        lines << ''
      end

      current_length += 1
    end

    lines
  end

  def select_word_for_length(available_words, used_words)
    return nil unless available_words

    unused_words = available_words.reject { |word| used_words.include?(word) }
    unused_words.sample
  end

  def extract_clean_words_for_snowball(content, min_length)
    content.downcase
           .gsub(/[^\w\s'-]/, ' ')
           .split(/\s+/)
           .reject { |word| word.empty? || word.length < min_length }
           .grep(/\A[a-z'-]+\z/)
           .uniq
  end
end
