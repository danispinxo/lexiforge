require 'timeout'

class DefinitionalGenerator < BaseGenerator
  protected

  def default_method
    'definitional'
  end

  private

  def generate_definitional(options = {})
    config = extract_definitional_config(options)
    words = extract_words_with_positions

    validation_error = validate_minimum_words
    return validation_error if validation_error

    section_words = select_text_section(words, config[:section_length])

    selected_words = select_words_from_section(section_words, config[:words_to_replace])

    reconstruct_text_with_definition_replacements(selected_words)
  end

  def extract_definitional_config(options)
    defaults = PoemGenerationConstants::DEFAULTS[:definitional]
    {
      preserve_structure: options[:preserve_structure] || true,
      section_length: options[:section_length] || defaults[:section_length],
      words_to_replace: options[:words_to_replace] || defaults[:words_to_replace]
    }
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
    return false if word.length < PoemGenerationConstants::VALIDATION[:minimum_word_length]

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
    apply_replacements_to_text(original_segment, replacements, start_pos)
  end
end
