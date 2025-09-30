require 'set'

class AbecedarianGenerator < BaseGenerator
  protected

  def default_method
    'abecedarian'
  end

  private

  def generate_abecedarian(options = {})
    config = extract_abecedarian_config(options)
    words = extract_words_in_order

    validation_error = validate_minimum_words
    return validation_error if validation_error

    lines = generate_abecedarian_lines(words, config)

    lines.join("\n")
  end

  def extract_abecedarian_config(options)
    defaults = PoemGenerationConstants::DEFAULTS[:abecedarian]
    {
      num_lines: 26, # Always 26 lines (one for each letter)
      words_per_line: options[:words_per_line] || defaults[:words_per_line],
      allow_empty_lines: true # Always allow empty lines
    }
  end

  def extract_words_in_order
    @source_text.content
                .downcase
                .gsub(/[^\w\s]/, '')
                .split
                .reject { |word| word.length < 2 }
  end

  def generate_abecedarian_lines(words, config)
    lines = []
    alphabet = ('a'..'z').to_a
    used_positions = Set.new

    alphabet.each do |letter|
      line = find_line_starting_with_letter(words, letter, config[:words_per_line], used_positions)

      lines << if line.empty?
                 '' # Always use empty lines when no words found
               else
                 line.join(' ').capitalize
               end
    end

    lines
  end

  def find_line_starting_with_letter(words, target_letter, words_per_line, used_positions)
    # Find all positions where words start with the target letter
    matching_positions = words.each_with_index.select do |word, index|
      word[0] == target_letter && used_positions.exclude?(index)
    end.map(&:last)

    return [] if matching_positions.empty?

    # Pick a random starting position
    start_position = matching_positions.sample

    # Extract the sequence of words starting from that position
    end_position = [start_position + words_per_line - 1, words.length - 1].min
    selected_words = words[start_position..end_position]

    # Mark these positions as used
    (start_position..end_position).each { |pos| used_positions.add(pos) }

    selected_words
  end
end
