require 'timeout'

class NPlusSevenGenerator < BaseGenerator
  protected

  def default_method
    'n_plus_seven'
  end

  private

  def generate_n_plus_seven(options = {})
    config = extract_n_plus_seven_config(options)
    words = extract_words_with_positions

    validation_error = validate_minimum_words(10)
    return validation_error if validation_error

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
end
