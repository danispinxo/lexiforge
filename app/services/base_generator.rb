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

  def extract_clean_words(min_length: PoemGenerationConstants::VALIDATION[:minimum_word_length],
                          preserve_punctuation: false)
    content = @source_text.content

    if preserve_punctuation
      content.downcase
             .gsub(/[^\w\s'-]/, ' ')
             .split(/\s+/)
             .reject { |word| word.empty? || word.length < min_length }
             .grep(/\A[a-z'-]+\z/)
             .grep_v(/\d/)
             .uniq
    else
      content.downcase
             .gsub(/[^\w\s]/, '')
             .split
             .reject { |word| word.length < min_length }
             .grep(/\A[a-z]+\z/)
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

  def extract_sentences(min_length: PoemGenerationConstants::TEXT_PROCESSING[:sentence_min_length], min_words: PoemGenerationConstants::TEXT_PROCESSING[:sentence_min_words])
    @source_text.content
                .gsub(/\s+/, ' ')
                .split(/[.!?]+/)
                .map(&:strip)
                .reject { |sentence| sentence.length < min_length || sentence.split.length < min_words }
                .map { |sentence| sentence.gsub(/[^\w\s]/, '') }
  end

  def validate_minimum_words(min_count = PoemGenerationConstants::VALIDATION[:minimum_words])
    words = extract_clean_words
    return 'Not enough words in source text' if words.length < min_count

    nil
  end

  def validate_minimum_content(min_length = PoemGenerationConstants::VALIDATION[:minimum_content_length])
    content = @source_text.content.strip
    return 'Not enough content in source text' if content.length < min_length

    nil
  end

  def validate_required_param(param, param_name)
    return "#{param_name.humanize} is required" if param.blank?

    nil
  end

  def validate_max_limit(param, param_name, max_value)
    return "#{param_name.humanize} cannot exceed #{max_value}" if param && param > max_value

    nil
  end

  def validate_min_limit(param, param_name, min_value)
    return "#{param_name.humanize} must be at least #{min_value}" if param && param < min_value

    nil
  end

  def validate_range(param, param_name, min_value, max_value)
    if param && (param < min_value || param > max_value)
      return "#{param_name.humanize} must be between #{min_value} and #{max_value}"
    end

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
    PoemGenerationConstants::WORD_RANGES[length_type.to_sym] || PoemGenerationConstants::WORD_RANGES[:medium]
  end

  def select_random_subset(array, count)
    return array if count >= array.length

    array.sample(count)
  end
end
