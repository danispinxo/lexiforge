require 'timeout'

class NPlusSevenGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'n_plus_seven'

    case method
    when 'n_plus_seven'
      generate_n_plus_seven(options)
    else
      raise "Invalid method: #{method}"
    end
  end

  private

  def generate_n_plus_seven(options = {})
    config = extract_n_plus_seven_config(options)
    words = extract_words_with_positions

    return 'Not enough words in source text' if words.length < 10

    selected_words = select_random_word_subset(words, config[:words_to_select])

    reconstruct_text_with_replacements(selected_words, config[:offset])
  end

  def extract_n_plus_seven_config(options)
    {
      offset: options[:offset] || 7,
      preserve_structure: options[:preserve_structure] || true,
      words_to_select: options[:words_to_select] || 50
    }
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

  def select_random_word_subset(words, words_to_select)
    start_index = rand([words.length - words_to_select + 1, 1].max)
    selected_count = [words_to_select, words.length - start_index].min

    words[start_index, selected_count]
  end

  def noun?(word)
    return false if word.length < 2

    DictionaryWord.exists?(word: word.downcase, part_of_speech: 'n')
  end

  def find_n_plus_seven_replacement(original_word, offset)
    replacement_record = DictionaryWord.find_n_plus_seven(original_word, offset)
    replacement_record&.word
  rescue StandardError
    nil
  end

  def reconstruct_text_with_replacements(selected_words, offset)
    sorted_words = selected_words.sort_by { |w| w[:position] }
    start_pos, end_pos = calculate_text_range(sorted_words)
    original_segment = @source_text.content[start_pos...end_pos]
    replacements = build_replacements_map(sorted_words, offset)

    apply_replacements_to_text(original_segment, replacements, start_pos)
  end

  def calculate_text_range(sorted_words)
    start_pos = sorted_words.first[:position]
    end_pos = sorted_words.last[:position] + sorted_words.last[:length]
    [start_pos, end_pos]
  end

  def build_replacements_map(sorted_words, offset)
    replacements = {}
    sorted_words.each do |word_data|
      next unless noun?(word_data[:word])

      replacement = find_n_plus_seven_replacement(word_data[:word], offset)
      next unless replacement

      replacements[word_data[:position]] = {
        original: word_data[:word],
        replacement: replacement,
        length: word_data[:length]
      }
    end
    replacements
  end

  def apply_replacements_to_text(original_segment, replacements, start_pos)
    result = original_segment.dup
    # Apply replacements in reverse order to avoid position shifts
    replacements.keys.sort.reverse_each do |pos|
      replacement_data = replacements[pos]
      relative_pos = pos - start_pos
      result[relative_pos, replacement_data[:length]] = replacement_data[:replacement]
    end
    result
  end
end
