require 'set'

class KwicGenerator < BaseGenerator
  protected

  def default_method
    'kwic'
  end

  private

  def generate_kwic(options = {})
    keyword = options[:keyword]&.downcase&.strip
    num_lines = options[:num_lines] || 10
    context_window = options[:context_window] || 3

    validation_error = validate_required_param(keyword, 'keyword')
    return validation_error if validation_error

    sentences = extract_sentences
    return 'Not enough sentences in source text' if sentences.empty?

    kwic_lines = find_keyword_contexts(sentences, keyword, context_window)

    return "Keyword '#{keyword}' not found in source text. Try a different word." if kwic_lines.empty?

    selected_lines = kwic_lines.sample(num_lines)
    selected_lines.join("\n")
  end

  def find_keyword_contexts(sentences, keyword, context_window)
    kwic_lines = []

    sentences.each do |sentence|
      words = sentence.downcase.split

      keyword_positions = words.each_index.select { |i| words[i] == keyword }

      keyword_positions.each do |pos|
        line = build_context_line(words, pos, context_window)
        kwic_lines << line if line
      end
    end

    kwic_lines.uniq
  end

  def build_context_line(words, keyword_pos, context_window)
    return nil if words.empty? || keyword_pos >= words.length

    start_pos = [0, keyword_pos - context_window].max
    end_pos = [words.length - 1, keyword_pos + context_window].min

    context_words = words[start_pos..end_pos]

    line = context_words.join(' ')
    line[0] = line[0].upcase if line.length.positive?

    line
  end
end
