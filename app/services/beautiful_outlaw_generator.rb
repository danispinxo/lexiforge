class BeautifulOutlawGenerator < BaseGenerator
  protected

  def default_method
    'beautiful_outlaw'
  end

  private

  def generate_beautifuloutlaw(options = {})
    config = extract_beautiful_outlaw_config(options)
    
    hidden_word_error = validate_required_param(config[:hidden_word], 'hidden_word')
    return hidden_word_error if hidden_word_error

    words = extract_clean_words
    validation_error = validate_minimum_words(PoemGenerationConstants::VALIDATION[:minimum_beautiful_outlaw_words])
    return validation_error if validation_error

    stanzas = generate_beautiful_outlaw_stanzas(words, config)
    return 'Unable to generate poem with the given constraints' if stanzas.empty?

    stanzas.map { |stanza| stanza.join("\n") }.join("\n\n")
  end

  def extract_beautiful_outlaw_config(options)
    defaults = PoemGenerationConstants::DEFAULTS[:beautiful_outlaw]
    {
      hidden_word: options[:hidden_word]&.downcase&.gsub(/[^a-z]/, '') || '',
      lines_per_stanza: options[:lines_per_stanza] || defaults[:lines_per_stanza],
      words_per_line: options[:words_per_line] || defaults[:words_per_line]
    }
  end

  def generate_beautiful_outlaw_stanzas(words, config)
    hidden_word = config[:hidden_word]
    stanzas = []

    hidden_word.each_char.with_index do |forbidden_letter, index|
      stanza = create_single_stanza(words, forbidden_letter, config)
      stanzas << stanza if stanza && !stanza.empty?
    end

    stanzas
  end

  def create_single_stanza(words, forbidden_letter, config)
    available_words = words.reject { |word| word.include?(forbidden_letter) }
    
    return nil if available_words.length < config[:words_per_line]

    stanza_lines = []
    config[:lines_per_stanza].times do
      line = create_single_line(available_words, config[:words_per_line])
      stanza_lines << line if line
    end

    return nil if stanza_lines.empty?
    
    stanza_lines.compact
  end

  def create_single_line(available_words, words_per_line)
    return nil if available_words.length < words_per_line

    selected_words = select_diverse_words(available_words, words_per_line)
    return nil if selected_words.empty?
    
    selected_words.join(' ').capitalize
  end

  def select_diverse_words(available_words, count)
    return [] if available_words.length < count
    
    available_words.sample(count)
  end


end
