class MesosticGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'mesostic'

    case method
    when 'mesostic'
      generate_mesostic(options)
    else
      raise "Invalid method: #{method}"
    end
  end

  private

  def generate_mesostic(options = {})
    spine_word = options[:spine_word]

    return 'Spine word is required for mesostic generation' if spine_word.blank?

    words = extract_clean_words
    return 'Not enough words in source text' if words.length < 10

    mesostic_lines = build_mesostic_lines(words, spine_word)

    return 'Could not generate mesostic poem with given spine word' if mesostic_lines.empty?

    mesostic_lines.join("\n")
  end

  def build_mesostic_lines(words, spine_word)
    lines = []
    spine_words = spine_word.downcase.split(/\s+/)

    spine_words.each_with_index do |spine_word_part, stanza_index|
      stanza_lines = []

      spine_word_part.each_char.with_index do |target_letter, position|
        matching_word = find_word_with_letter_at_position(words, target_letter, position)

        break unless matching_word

        stanza_lines << matching_word
      end

      lines.concat(stanza_lines)

      lines << '' if stanza_index < spine_words.length - 1 && !stanza_lines.empty?
    end

    lines
  end

  def find_word_with_letter_at_position(words, target_letter, position)
    words.find do |word|
      word.length > position && word[position] == target_letter
    end
  end

  def extract_clean_words
    @source_text.content.downcase
                .gsub(/[^\w\s]/, '')
                .split
                .reject { |word| word.length < 2 }
                .uniq
  end
end
