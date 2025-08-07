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

      if stanza_index < spine_words.length - 1
        lines << ''
      end
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

  def extract_clean_words
    @source_text.content.downcase
                .gsub(/[^\w\s]/, '')
                .split
                .reject { |word| word.length < 2 }
  end
end
