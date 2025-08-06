class CutUpGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'cut_up'

    case method
    when 'cut_up'
      generate_cutup(options)
    else
      raise "Invalid method: #{method}"
    end
  end

  private

  def generate_cutup(options = {})
    config = extract_cutup_config(options)
    words = extract_clean_words

    return 'Not enough words in source text' if words.length < 10

    lines = generate_cutup_lines(words, config)
    lines.join("\n")
  end

  def extract_cutup_config(options)
    {
      num_lines: options[:num_lines] || 12,
      words_per_line: options[:words_per_line] || 6
    }
  end

  def extract_clean_words
    @source_text.content.downcase
                .gsub(/[^\w\s]/, '')
                .split
                .reject { |word| word.length < 2 }
                .uniq
  end

  def generate_cutup_lines(words, config)
    lines = []
    config[:num_lines].times do
      line = create_single_cutup_line(words, config[:words_per_line])
      lines << line
    end
    lines
  end

  def create_single_cutup_line(words, words_per_line)
    word_range = calculate_word_range(words_per_line)
    line_length = rand(word_range)
    line_words = words.sample(line_length)
    line_words.join(' ')
  end

  def calculate_word_range(words_per_line)
    case words_per_line
    when 3 then 3..4
    when 6 then 5..8
    when 10 then 8..12
    when 15 then 12..18
    else 5..7
    end
  end
end
