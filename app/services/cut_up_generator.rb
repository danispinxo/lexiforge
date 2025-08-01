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
      generate_cutup(options)
    end
  end

  private

  def generate_cutup(options = {})
    num_lines = options[:num_lines] || 12
    words_per_line = options[:words_per_line] || 6

    words = @source_text.content.downcase
                        .gsub(/[^\w\s]/, '')
                        .split
                        .reject { |word| word.length < 2 }
                        .uniq

    return 'Not enough words in source text' if words.length < 10

    lines = []
    num_lines.times do
      word_range = case words_per_line
                   when 3 then 3..4
                   when 6 then 5..7
                   when 10 then 8..12
                   when 15 then 12..18
                   else 5..7
                   end

      line_length = rand(word_range)
      line_words = words.sample(line_length)
      lines << line_words.join(' ')
    end

    lines.join("\n")
  end
end
