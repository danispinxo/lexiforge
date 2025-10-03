class Api::PoemsController < ApiController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_any_user!, only: %i[generate_poem my_poems update destroy download]
  before_action :set_poem, only: %i[show edit update destroy download]
  before_action :authorize_poem_owner!, only: %i[update destroy]
  before_action :set_source_text, only: %i[generate_poem]

  def index
    @poems = build_poems_query(Poem.public_poems)
    render_paginated_poems
  end

  def show
    render json: @poem, serializer: PoemDetailSerializer
  end

  def my_poems
    current_user = current_api_user || current_admin_user
    @poems = build_poems_query(Poem.for_author(current_user))
    render_paginated_poems
  end

  def new
    @poem = Poem.new
    @source_texts = SourceText.all
  end

  def edit
    @source_texts = SourceText.all
  end

  def create
    @poem = Poem.new(poem_params)

    if @poem.save
      render json: {
        success: true,
        message: 'Poem was successfully created.',
        poem: {
          id: @poem.id,
          title: @poem.title,
          content: @poem.content,
          technique_used: @poem.technique_used
        }
      }
    else
      render json: {
        success: false,
        errors: @poem.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  def update
    if @poem.update(poem_params)
      render json: {
        success: true,
        message: t('poems.notices.updated'),
        poem: PoemDetailSerializer.new(@poem).as_json
      }
    else
      render json: {
        success: false,
        message: 'Failed to update poem.',
        errors: @poem.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  def destroy
    @poem.destroy
    render json: {
      success: true,
      message: t('poems.notices.deleted')
    }
  end

  def generate_poem
    return render_blank_content_error if @source_text.content.blank?

    technique = determine_technique
    options = build_options(technique)
    content = generate_content(technique, options)

    @poem = build_poem(technique, content, options)

    if @poem.save
      technique_name = get_technique_display_name(technique, options)
      render_poem_generation_success(technique_name)
    else
      render_poem_save_error
    end
  end

  def download
    content = extract_plain_text_content(@poem.content)
    filename = sanitize_filename("#{@poem.title}.txt")

    send_data content,
              filename: filename,
              type: 'text/plain; charset=utf-8',
              disposition: 'attachment'
  end

  private

  def apply_search(scope, search_term)
    return scope if search_term.blank?

    scope.where(
      'title ILIKE ? OR content ILIKE ?',
      "%#{search_term}%", "%#{search_term}%"
    )
  end

  def apply_sorting(scope, sort_by, sort_direction)
    sort_by ||= 'created_at'
    sort_direction ||= 'desc'

    sort_direction = 'desc' unless %w[asc desc].include?(sort_direction.downcase)

    case sort_by
    when 'title'
      scope.order(title: sort_direction)
    when 'technique_used'
      scope.order(technique_used: sort_direction)
    when 'word_count'
      scope.order(Arel.sql("LENGTH(content) #{sort_direction}"))
    when 'created_at'
      scope.order(created_at: sort_direction)
    when 'author'
      scope.joins("LEFT JOIN users ON poems.author_type = 'User' AND poems.author_id = users.id")
           .joins("LEFT JOIN admin_users ON poems.author_type = 'AdminUser' AND poems.author_id = admin_users.id")
           .order(Arel.sql("COALESCE(users.username, admin_users.email) #{sort_direction}"))
    else
      scope.order(created_at: :desc)
    end
  end

  def build_poems_query(base_scope)
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    scope = base_scope.includes(:source_text, :author)
    scope = apply_search(scope, params[:search])
    scope = apply_sorting(scope, params[:sort_by], params[:sort_direction])
    scope.page(page).per(per_page)
  end

  def render_paginated_poems
    render json: {
      poems: ActiveModel::Serializer::CollectionSerializer.new(
        @poems, serializer: PoemSerializer
      ),
      pagination: pagination_metadata
    }
  end

  def pagination_metadata
    {
      current_page: @poems.current_page,
      total_pages: @poems.total_pages,
      total_count: @poems.total_count,
      per_page: @poems.limit_value,
      next_page: @poems.next_page,
      prev_page: @poems.prev_page
    }
  end

  def determine_technique
    permitted_params = generation_params
    permitted_params[:method] || 'cut_up'
  end

  def build_options(technique)
    permitted_params = generation_params
    options = { method: technique }

    builder_method = "build_#{technique.tr('-', '_')}_options"
    send(builder_method, options, permitted_params) if respond_to?(builder_method, true)

    options
  end

  def build_cut_up_options(options, permitted_params)
    options[:num_lines] = (permitted_params[:num_lines] || 12).to_i
    options[:words_per_line] = (permitted_params[:words_per_line] || 6).to_i
  end

  def build_erasure_options(options, permitted_params)
    options[:num_pages] = (permitted_params[:num_pages] || 3).to_i
    options[:words_per_page] = (permitted_params[:words_per_page] || 50).to_i
    options[:words_to_keep] = (permitted_params[:words_to_keep] || 8).to_i
    options[:is_blackout] = ['true', true].include?(permitted_params[:is_blackout])
  end

  def build_snowball_options(options, permitted_params)
    options[:num_lines] = (permitted_params[:num_lines] || 10).to_i
    options[:min_word_length] = (permitted_params[:min_word_length] || 1).to_i
  end

  def build_mesostic_options(options, permitted_params)
    options[:spine_word] = permitted_params[:spine_word] if permitted_params[:spine_word].present?
  end

  def build_n_plus_seven_options(options, permitted_params)
    options[:offset] = (permitted_params[:offset] || 7).to_i
    options[:words_to_select] = (permitted_params[:words_to_select] || 50).to_i
    options[:preserve_structure] = ['true', true].include?(permitted_params[:preserve_structure])
  end

  def build_definitional_options(options, permitted_params)
    options[:section_length] = (permitted_params[:section_length] || 200).to_i
    options[:words_to_replace] = (permitted_params[:words_to_replace] || 20).to_i
    options[:preserve_structure] = ['true', true].include?(permitted_params[:preserve_structure])
  end

  def build_found_poem_options(options, permitted_params)
    options[:num_lines] = (permitted_params[:num_lines] || 10).to_i
    options[:line_length] = permitted_params[:line_length] || 'medium'
  end

  def build_kwic_options(options, permitted_params)
    options[:keyword] = permitted_params[:keyword] if permitted_params[:keyword].present?
    options[:num_lines] = (permitted_params[:num_lines] || 10).to_i
    options[:context_window] = (permitted_params[:context_window] || 3).to_i
    options[:use_all_appearances] = ['true', true].include?(permitted_params[:use_all_appearances])
  end

  def build_prisoners_constraint_options(options, permitted_params)
    options[:num_words] = (permitted_params[:num_words] || 20).to_i
    options[:constraint_type] = permitted_params[:constraint_type] || 'full_constraint'
  end

  def build_beautiful_outlaw_options(options, permitted_params)
    options[:hidden_word] = permitted_params[:hidden_word] if permitted_params[:hidden_word].present?
    options[:lines_per_stanza] = (permitted_params[:lines_per_stanza] || 4).to_i
    options[:words_per_line] = (permitted_params[:words_per_line] || 6).to_i
  end

  def build_lipogram_options(options, permitted_params)
    options[:num_words] = (permitted_params[:num_words] || 20).to_i
    options[:line_length] = permitted_params[:line_length] || 'medium'
    options[:letters_to_omit] = permitted_params[:letters_to_omit] if permitted_params[:letters_to_omit].present?
  end

  def build_reverse_lipogram_options(options, permitted_params)
    options[:num_words] = (permitted_params[:num_words] || 20).to_i
    options[:line_length] = permitted_params[:line_length] || 'medium'
    options[:letters_to_use] = permitted_params[:letters_to_use] if permitted_params[:letters_to_use].present?
  end

  def build_abecedarian_options(options, permitted_params)
    options[:words_per_line] = (permitted_params[:words_per_line] || 5).to_i
  end

  def build_univocal_options(options, permitted_params)
    options[:num_words] = (permitted_params[:num_words] || 30).to_i
    options[:line_length] = permitted_params[:line_length] || 'medium'
    options[:vowel_to_use] = permitted_params[:vowel_to_use] if permitted_params[:vowel_to_use].present?
  end

  def build_aleatory_options(options, permitted_params)
    options[:num_lines] = (permitted_params[:num_lines] || 10).to_i
    options[:line_length] = permitted_params[:line_length] || 'medium'
    options[:randomness_factor] = (permitted_params[:randomness_factor] || 0.7).to_f
  end

  def build_alliterative_options(options, permitted_params)
    options[:num_lines] = (permitted_params[:num_lines] || 8).to_i
    options[:line_length] = permitted_params[:line_length] || 'medium'
    return if permitted_params[:alliteration_letter].blank?

    options[:alliteration_letter] =
      permitted_params[:alliteration_letter]
  end

  def generate_content(technique, options)
    generator_class = technique_to_generator_class(technique)
    generator = generator_class.new(@source_text)
    generator.generate(options)
  end

  def technique_to_generator_class(technique)
    technique_generators = {
      'cut_up' => CutUpGenerator,
      'erasure' => ErasureGenerator,
      'snowball' => SnowballGenerator,
      'mesostic' => MesosticGenerator,
      'n_plus_seven' => NPlusSevenGenerator,
      'definitional' => DefinitionalGenerator,
      'found' => FoundPoemGenerator,
      'kwic' => KwicGenerator,
      'prisoners_constraint' => PrisonersConstraintGenerator,
      'beautiful_outlaw' => BeautifulOutlawGenerator,
      'lipogram' => LipogramGenerator,
      'reverse_lipogram' => ReverseLipogramGenerator,
      'abecedarian' => AbecedarianGenerator,
      'univocal' => UnivocalGenerator,
      'aleatory' => AleatoryGenerator,
      'alliterative' => AlliterativeGenerator
    }

    technique_generators[technique] || raise("Unknown technique: #{technique}")
  end

  def build_poem(technique, content, options)
    technique_used = get_technique_used(technique, options)
    author = current_api_user || current_admin_user
    is_public = ActiveModel::Type::Boolean.new.cast(params[:is_public])

    @source_text.poems.build(
      title: generate_poem_title(content, technique_used),
      content: content,
      technique_used: technique_used,
      author: author,
      is_public: is_public
    )
  end

  def get_technique_used(technique, options)
    case technique
    when 'cut_up'
      'cutup'
    when 'erasure'
      options[:is_blackout] ? 'blackout' : 'erasure'
    when 'n_plus_seven'
      'n+7'
    when 'beautiful_outlaw'
      'beautiful_outlaw'
    else
      technique
    end
  end

  def get_technique_display_name(technique, options)
    case technique
    when 'cut_up'
      'cut-up'
    when 'erasure'
      options[:is_blackout] ? 'blackout' : 'erasure'
    when 'n_plus_seven'
      'n+7'
    when 'kwic'
      'KWIC'
    when 'prisoners_constraint'
      "prisoner's constraint"
    when 'beautiful_outlaw'
      'beautiful outlaw'
    else
      technique
    end
  end

  def render_poem_generation_success(technique_name)
    render json: {
      success: true,
      message: "#{technique_name.capitalize} poem successfully generated from '#{@source_text.title}'!",
      poem: poem_json_data
    }
  end

  def poem_json_data
    {
      id: @poem.id,
      title: @poem.title,
      content: @poem.content,
      technique_used: @poem.technique_used,
      source_text_id: @poem.source_text_id
    }
  end

  def render_blank_content_error
    render json: {
      success: false,
      message: 'Cannot generate poem: source text has no content.'
    }, status: :unprocessable_content
  end

  def render_poem_save_error
    render json: {
      success: false,
      message: "Failed to generate poem: #{@poem.errors.full_messages.join(', ')}"
    }, status: :unprocessable_content
  end

  def set_poem
    @poem = Poem.find(params[:id])
  end

  def set_source_text
    @source_text = SourceText.find(params[:id])
  end

  def poem_params
    params.expect(poem: %i[title content technique_used source_text_id is_public])
  end

  def generation_params
    params.permit(:method, :spine_word, :num_lines, :words_per_line, :size,
                  :num_pages, :words_per_page, :words_to_keep, :is_blackout,
                  :min_word_length, :offset, :words_to_select, :preserve_structure,
                  :section_length, :words_to_replace, :line_length, :keyword, :context_window,
                  :use_all_appearances, :num_words, :constraint_type, :hidden_word, :lines_per_stanza,
                  :letters_to_omit, :letters_to_use, :vowel_to_use, :alliteration_letter, :randomness_factor)
  end

  def authenticate_any_user!
    return if current_api_user || current_admin_user

    render json: {
      success: false,
      message: 'Authentication required'
    }, status: :unauthorized
  end

  def authorize_poem_owner!
    current_user = current_api_user || current_admin_user
    return if current_user && @poem.author == current_user

    render json: {
      success: false,
      message: 'You can only edit your own poems'
    }, status: :forbidden
  end

  def generate_poem_title(poem_content, technique)
    visible_text = extract_visible_text_from_content(poem_content)

    words = visible_text.gsub(/[^\w\s]/, ' ').split.reject(&:empty?)

    return "Untitled #{technique.capitalize}" if words.empty?

    num_words = rand(1..4)
    max_start_index = [0, words.length - num_words].max
    start_index = rand(0..max_start_index)

    selected_words = words[start_index, num_words]
    selected_words.join(' ').capitalize
  end

  def extract_visible_text_from_content(content)
    visible_text = if content.strip.start_with?('{') && content.strip.end_with?('}')
                     begin
                       parsed_json = JSON.parse(content)
                       if parsed_json.is_a?(Hash) && parsed_json['pages']
                         visible_pages = parsed_json['pages'].pluck('content').compact
                         visible_pages.join(' ')
                       else
                         content
                       end
                     rescue JSON::ParserError
                       content
                     end
                   else
                     content.lines
                            .map(&:strip)
                            .reject(&:empty?)
                            .join(' ')
                   end

    strip_html_tags(visible_text)
  end

  def strip_html_tags(text)
    text.gsub(/<[^>]*>/, '')
        .gsub(/&[a-zA-Z]+;/, '')
        .gsub(/█+/, '')
        .squeeze(' ')
        .strip
  end

  def extract_plain_text_content(content)
    if content.strip.start_with?('{') && content.strip.end_with?('}')
      begin
        parsed_json = JSON.parse(content)
        if parsed_json.is_a?(Hash) && parsed_json['pages']
          parsed_json['pages'].map do |page|
            page_content = page['content']
            clean_content = strip_html_tags(page_content)
            "Page #{page['number']}\n\n#{clean_content}"
          end.join("\n\n#{'=' * 50}\n\n")
        else
          content
        end
      rescue JSON::ParserError
        content
      end
    else
      content
    end
  end

  def sanitize_filename(filename)
    filename.gsub(/[^\w\-_.]/, '_').squeeze('_')
  end
end
