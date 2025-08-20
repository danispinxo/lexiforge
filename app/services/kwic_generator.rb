require 'set'

class KwicGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'kwic'

    case method
    when 'kwic'
      generate_kwic(options)
    else
      raise "Invalid method: #{method}"
    end
  end

  private

  def generate_kwic(options = {})
    keyword = options[:keyword]&.downcase&.strip
    num_lines = options[:num_lines] || 10
    context_window = options[:context_window] || 3

    return 'Keyword is required for KWIC generation' if keyword.blank?

    sentences = extract_sentences
    return 'Not enough sentences in source text' if sentences.length < 3

    kwic_lines = find_keyword_contexts(sentences, keyword, context_window)

    return "Keyword '#{keyword}' not found in source text. Try a different word." if kwic_lines.empty?

    selected_lines = kwic_lines.sample(num_lines)
    selected_lines.join("\n")
  end

  def extract_sentences
    @source_text.content
                .gsub(/\s+/, ' ')
                .split(/[.!?]+/)
                .map(&:strip)
                .reject { |sentence| sentence.length < 10 || sentence.split.length < 3 }
                .map { |sentence| sentence.gsub(/[^\w\s]/, '') }
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
    line[0] = line[0].upcase if line.length > 0

    line
  end

  def extract_clean_words
    @source_text.content.downcase
                .gsub(/[^\w\s]/, '')
                .split
                .reject { |word| word.length < 2 }
  end
end
