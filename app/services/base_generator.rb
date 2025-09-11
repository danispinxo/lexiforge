class BaseGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || default_method

    raise "Invalid method: #{method}. Only supported method: #{default_method}" unless method == default_method

    method_name = "generate_#{method.delete('_')}"
    send(method_name, options)
  end

  protected

  def default_method
    raise NotImplementedError, 'Subclasses must define default_method'
  end

  def extract_clean_words(min_length: 2, preserve_punctuation: false)
    content = @source_text.content

    if preserve_punctuation
      content.downcase
             .gsub(/[^\w\s'-]/, ' ')
             .split(/\s+/)
             .reject { |word| word.empty? || word.length < min_length }
             .grep(/\A[a-z'-]+\z/)
             .uniq
    else
      content.downcase
             .gsub(/[^\w\s]/, '')
             .split
             .reject { |word| word.length < min_length }
             .uniq
    end
  end

  def extract_words_with_positions
    words = []
    current_word = ''
    word_start = 0

    @source_text.content.each_char.with_index do |char, index|
      if /\w/.match?(char)
        current_word += char
        word_start = index if current_word.length == 1
      elsif current_word.length.positive?
        words << {
          word: current_word,
          position: word_start,
          length: current_word.length
        }
        current_word = ''
      end
    end

    if current_word.length.positive?
      words << {
        word: current_word,
        position: word_start,
        length: current_word.length
      }
    end

    words
  end

  def extract_sentences(min_length: 10, min_words: 3)
    @source_text.content
                .gsub(/\s+/, ' ')
                .split(/[.!?]+/)
                .map(&:strip)
                .reject { |sentence| sentence.length < min_length || sentence.split.length < min_words }
                .map { |sentence| sentence.gsub(/[^\w\s]/, '') }
  end

  def validate_minimum_words(min_count = 10)
    words = extract_clean_words
    return 'Not enough words in source text' if words.length < min_count

    nil
  end

  def validate_minimum_content(min_length = 100)
    content = @source_text.content.strip
    return 'Not enough content in source text' if content.length < min_length

    nil
  end

  def validate_required_param(param, param_name)
    return "#{param_name.humanize} is required" if param.blank?

    nil
  end

  def calculate_text_range(sorted_words)
    start_pos = sorted_words.first[:position]
    end_pos = sorted_words.last[:position] + sorted_words.last[:length]
    [start_pos, end_pos]
  end

  def apply_replacements_to_text(original_segment, replacements, start_pos)
    result = original_segment.dup
    replacements.keys.sort.reverse_each do |pos|
      replacement_data = replacements[pos]
      relative_pos = pos - start_pos
      result[relative_pos, replacement_data[:length]] = replacement_data[:replacement]
    end
    result
  end

  def random_range_for_length(length_type)
    ranges = {
      'very_short' => 1..2,
      'short' => 3..4,
      'medium' => 5..7,
      'long' => 8..10,
      'very_long' => 10..15
    }
    ranges[length_type] || ranges['medium']
  end

  def select_random_subset(array, count)
    return array if count >= array.length

    array.sample(count)
  end
end
