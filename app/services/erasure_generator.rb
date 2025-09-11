class ErasureGenerator < BaseGenerator
  protected

  def default_method
    'erasure'
  end

  private

  def generate_erasure(options = {})
    config = extract_erasure_config(options)
    original_text = @source_text.content.strip

    validation_error = validate_minimum_content(100)
    return validation_error if validation_error

    pages = generate_erasure_pages(original_text, config)
    format_erasure_result(pages, config[:is_blackout])
  end

  def extract_erasure_config(options)
    {
      num_pages: options[:num_pages] || 3,
      words_per_page: options[:words_per_page] || 50,
      words_to_keep: options[:words_to_keep] || 8,
      is_blackout: options[:is_blackout] || false
    }
  end

  def generate_erasure_pages(original_text, config)
    pages = []

    config[:num_pages].times do
      page = create_single_erasure_page(original_text, config)
      pages << page if page
    end

    pages
  end

  def create_single_erasure_page(original_text, config)
    start_pos = calculate_random_start_position(original_text, config[:words_per_page])
    start_pos = find_word_boundary(original_text, start_pos, :start)

    excerpt = extract_text_excerpt(original_text, start_pos, config[:words_per_page])
    return nil if excerpt.strip.empty?

    create_prose_erasure(excerpt, words_to_keep: config[:words_to_keep], is_blackout: config[:is_blackout])
  end

  def calculate_random_start_position(text, words_per_page)
    max_start = [text.length - (words_per_page * 8), 0].max
    rand(max_start + 1)
  end

  def format_erasure_result(pages, is_blackout)
    {
      type: 'erasure_pages',
      is_blackout: is_blackout,
      pages: pages.map.with_index(1) do |page, index|
        {
          number: index,
          content: page
        }
      end
    }.to_json
  end

  def find_word_boundary(text, pos, direction)
    return boundary_edge_case(text, pos) if pos_at_edge?(text, pos)

    direction == :start ? find_start_boundary(text, pos) : pos
  end

  def pos_at_edge?(text, pos)
    pos <= 0 || pos >= text.length
  end

  def boundary_edge_case(text, pos)
    return 0 if pos <= 0

    text.length
  end

  def find_start_boundary(text, pos)
    pos = move_to_word_start(text, pos)
    skip_leading_whitespace(text, pos)
  end

  def move_to_word_start(text, pos)
    pos -= 1 while pos.positive? && !whitespace_char?(text[pos])
    pos
  end

  def skip_leading_whitespace(text, pos)
    pos += 1 while pos < text.length && whitespace_char?(text[pos])
    pos
  end

  def whitespace_char?(char)
    char =~ /\s/
  end

  def extract_text_excerpt(text, start_pos, target_word_count)
    excerpt = ''
    word_count = 0
    pos = start_pos

    while pos < text.length && word_count < target_word_count
      char = text[pos]
      excerpt += char

      word_count += 1 if pos == text.length - 1 || (char !~ /\s/ && pos + 1 < text.length && text[pos + 1] =~ /\s/)

      pos += 1
    end

    excerpt
  end

  def create_prose_erasure(text, words_to_keep:, is_blackout: false)
    words_with_spacing = extract_words_with_spacing(text)

    return text if words_with_spacing.length < 2

    keep_indices = select_words_to_keep(words_with_spacing, words_to_keep)
    build_erasure_result(words_with_spacing, keep_indices, is_blackout)
  end

  def select_words_to_keep(words_with_spacing, words_to_keep)
    word_indices = find_word_indices(words_with_spacing)
    total_words = word_indices.length
    words_to_keep_actual = [words_to_keep, total_words].min

    word_indices.sample(words_to_keep_actual)
  end

  def find_word_indices(words_with_spacing)
    word_indices = []
    words_with_spacing.each_with_index do |item, index|
      word_indices << index if item[:type] == :word
    end
    word_indices
  end

  def build_erasure_result(words_with_spacing, keep_indices, is_blackout)
    result = ''
    words_with_spacing.each_with_index do |item, index|
      result += format_item_for_erasure(item, index, keep_indices, is_blackout)
    end
    result
  end

  def format_item_for_erasure(item, index, keep_indices, is_blackout)
    case item[:type]
    when :space
      item[:text]
    when :word
      if keep_indices.include?(index)
        item[:text]
      elsif is_blackout
        "<span class='blackout-word'>#{'█' * item[:text].length}</span>"
      else
        ' ' * item[:text].length
      end
    end
  end

  def extract_words_with_spacing(text)
    result = []
    current_word = ''
    current_space = ''

    text.each_char do |char|
      if /\s/.match?(char)
        unless current_word.empty?
          result << { type: :word, text: current_word }
          current_word = ''
        end
        current_space += char
      else
        unless current_space.empty?
          result << { type: :space, text: current_space }
          current_space = ''
        end
        current_word += char
      end
    end

    result << { type: :word, text: current_word } unless current_word.empty?
    result << { type: :space, text: current_space } unless current_space.empty?

    result
  end
end
