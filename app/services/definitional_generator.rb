require 'timeout'

class DefinitionalGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'definitional'

    case method
    when 'definitional'
      generate_definitional(options)
    else
      raise "Invalid method: #{method}"
    end
  end

  private

  def generate_definitional(options = {})
    config = extract_definitional_config(options)
    words = extract_words_with_positions

    return 'Not enough words in source text' if words.length < 10

    section_words = select_text_section(words, config[:section_length])

    selected_words = select_words_from_section(section_words, config[:words_to_replace])

    reconstruct_text_with_definition_replacements(selected_words)
  end

  def extract_definitional_config(options)
    {
      preserve_structure: options[:preserve_structure] || true,
      section_length: options[:section_length] || 200,
      words_to_replace: options[:words_to_replace] || 20
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

  def select_text_section(words, section_length)
    max_start = [words.length - section_length, 0].max
    start_index = rand(max_start + 1)

    words[start_index, section_length]
  end

  def select_words_from_section(section_words, words_to_replace)
    word_indices = (0...section_words.length).to_a
    selected_indices = word_indices.sample([words_to_replace, section_words.length].min)

    selected_indices.map { |index| section_words[index] }
  end

  def definition?(word)
    return false if word.length < 2

    DictionaryWord.where(word: word.downcase).where.not(definition: [nil, '']).exists?
  end

  def find_definition_replacement(original_word)
    replacement_record = DictionaryWord.find_with_definition(original_word)
    return nil unless replacement_record&.definition

    definition = replacement_record.definition.strip
    definition = definition.gsub(/\s+/, ' ')
    remove_parentheses_content(definition)
  end

  def remove_parentheses_content(text)
    text = text.gsub(/\([^()]*\)/, '') while text =~ /\([^()]*\)/
    text.gsub(/\s+/, ' ').strip
  end

  def reconstruct_text_with_definition_replacements(selected_words)
    sorted_words = selected_words.sort_by { |w| w[:position] }
    start_pos, end_pos = calculate_text_range(sorted_words)
    original_segment = @source_text.content[start_pos...end_pos]
    replacements = build_definition_replacements_map(sorted_words)

    apply_definition_replacements_to_text(original_segment, replacements, start_pos)
  end

  def calculate_text_range(sorted_words)
    start_pos = sorted_words.first[:position]
    end_pos = sorted_words.last[:position] + sorted_words.last[:length]
    [start_pos, end_pos]
  end

  def build_definition_replacements_map(sorted_words)
    replacements = {}
    sorted_words.each do |word_data|
      next unless definition?(word_data[:word])

      replacement = find_definition_replacement(word_data[:word])
      next unless replacement

      replacements[word_data[:position]] = {
        original: word_data[:word],
        replacement: replacement,
        length: word_data[:length]
      }
    end
    replacements
  end

  def apply_definition_replacements_to_text(original_segment, replacements, start_pos)
    result = original_segment.dup

    replacements.keys.sort.reverse_each do |pos|
      replacement_data = replacements[pos]
      relative_pos = pos - start_pos
      result[relative_pos, replacement_data[:length]] = replacement_data[:replacement]
    end
    result
  end
end
