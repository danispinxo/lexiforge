class MesosticGenerator < BaseGenerator
  protected

  def default_method
    'mesostic'
  end

  private

  def generate_mesostic(options = {})
    spine_word = options[:spine_word]

    validation_error = validate_required_param(spine_word, 'spine_word')
    return validation_error if validation_error

    words = extract_clean_words
    validation_error = validate_minimum_words
    return validation_error if validation_error

    mesostic_lines = build_mesostic_lines(words, spine_word)

    return 'Could not generate mesostic poem with given spine word' if mesostic_lines.empty?

    mesostic_lines.join("\n")
  end

  def build_mesostic_lines(words, spine_word)
    lines = []
    spine_words = spine_word.downcase.split(/\s+/)
    current_word_index = 0

    spine_words.each_with_index do |spine_word_part, stanza_index|
      stanza_lines = []

      spine_word_part.each_char.with_index do |target_letter, position|
        result = find_word_with_letter_at_position(words, target_letter, position, current_word_index)

        break unless result[:found]

        stanza_lines << result[:word]
        current_word_index = result[:next_index]
      end

      lines.concat(stanza_lines)

      lines << '' if stanza_index < spine_words.length - 1
    end

    lines
  end

  def find_word_with_letter_at_position(words, target_letter, position, start_index)
    (start_index...words.length).each do |i|
      word = words[i]
      return { found: true, word: word, next_index: i + 1 } if word.length > position && word[position] == target_letter
    end

    { found: false, word: nil, next_index: start_index }
  end
end
