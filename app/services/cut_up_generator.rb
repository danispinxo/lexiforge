class CutUpGenerator < BaseGenerator
  protected

  def default_method
    'cut_up'
  end

  private

  def generate_cutup(options = {})
    config = extract_cutup_config(options)
    words = extract_clean_words

    validation_error = validate_minimum_words
    return validation_error if validation_error

    lines = generate_cutup_lines(words, config)
    lines.join("\n")
  end

  def extract_cutup_config(options)
    defaults = PoemGenerationConstants::DEFAULTS[:cut_up]
    {
      num_lines: options[:num_lines] || defaults[:num_lines],
      words_per_line: options[:words_per_line] || defaults[:words_per_line]
    }
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
    PoemGenerationConstants::CUT_UP_RANGES[words_per_line] || PoemGenerationConstants::CUT_UP_RANGES[:default]
  end
end
