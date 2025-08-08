require 'timeout'

class NPlusSevenGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate(options = {})
    method = options[:method] || 'n_plus_seven'

    case method
    when 'n_plus_seven'
      generate_n_plus_seven(options)
    else
      raise "Invalid method: #{method}"
    end
  end

  private

  def generate_n_plus_seven(options = {})
    config = extract_n_plus_seven_config(options)
    words = extract_words_with_positions

    return 'Not enough words in source text' if words.length < 10

    selected_words = select_random_word_subset(words, config[:words_to_select])
    
    processed_words = []
    
    selected_words.each do |word|
      if is_noun?(word)
        replacement = find_n_plus_seven_replacement(word, config[:offset])
        if replacement
          processed_words << replacement
        else
          processed_words << word
        end
      else
        processed_words << word
      end
    end
    
    processed_words.join(' ')
  end

  def extract_n_plus_seven_config(options)
    {
      offset: options[:offset] || 7,
      preserve_structure: options[:preserve_structure] || true,
      words_to_select: options[:words_to_select] || 50
    }
  end

  def extract_words_with_positions
    words = []
    current_word = ''
    current_position = 0
    word_start = 0

    @source_text.content.each_char.with_index do |char, index|
      if /\w/.match?(char)
        current_word += char
        word_start = index if current_word.length == 1
      else
        if current_word.length > 0
          words << {
            word: current_word,
            position: word_start,
            length: current_word.length
          }
          current_word = ''
        end
      end
    end

    if current_word.length > 0
      words << {
        word: current_word,
        position: word_start,
        length: current_word.length
      }
    end

    words
  end

  def select_random_word_subset(words, words_to_select)
    start_index = rand([words.length - words_to_select + 1, 1].max)
    selected_count = [words_to_select, words.length - start_index].min
    
    words[start_index, selected_count].map { |w| w[:word] }
  end

  def is_noun?(word)
    return false if word.length < 2
    DictionaryWord.exists?(word: word.downcase, part_of_speech: 'n')
  end

  def find_n_plus_seven_replacement(original_word, offset)
    replacement_record = DictionaryWord.find_n_plus_seven(original_word, offset)
    replacement_record&.word
  rescue
    nil
  end
end

