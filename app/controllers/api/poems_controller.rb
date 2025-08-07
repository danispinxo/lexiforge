class Api::PoemsController < ApiController
  before_action :set_poem, only: %i[show edit update destroy]
  before_action :set_source_text, only: %i[generate_cut_up generate_erasure generate_snowball generate_mesostic]

  def index
    @poems = Poem.includes(:source_text).order(created_at: :desc)
    render json: @poems, each_serializer: PoemSerializer
  end

  def show
    render json: @poem, serializer: PoemDetailSerializer
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
      }, status: :unprocessable_entity
    end
  end

  def update
    if @poem.update(poem_params)
      redirect_to @poem, notice: t('poems.notices.updated')
    else
      @source_texts = SourceText.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @poem.destroy
    redirect_to poems_url, notice: t('poems.notices.deleted')
  end

  def generate_cut_up
    return render_blank_content_error if @source_text.content.blank?

    options = build_cut_up_options
    cut_up_content = generate_cut_up_content(options)

    @poem = build_cut_up_poem(cut_up_content)

    if @poem.save
      render_poem_generation_success('cut-up')
    else
      render_poem_save_error
    end
  end

  private

  def build_cut_up_options
    method = params[:method] || 'cut_up'
    options = { method: method }

    if method == 'cut_up'
      options[:num_lines] = (params[:num_lines] || 12).to_i
      options[:words_per_line] = (params[:words_per_line] || 6).to_i
    else
      options[:size] = params[:size] || 'medium'
    end

    options
  end

  def generate_cut_up_content(options)
    generator = CutUpGenerator.new(@source_text)
    generator.generate(options)
  end

  def build_cut_up_poem(content)
    @source_text.poems.build(
      title: generate_poem_title(@source_text, 'cutup'),
      content: content,
      technique_used: 'cutup'
    )
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
    }, status: :unprocessable_entity
  end

  def render_poem_save_error
    render json: {
      success: false,
      message: "Failed to generate poem: #{@poem.errors.full_messages.join(', ')}"
    }, status: :unprocessable_entity
  end

  public

  def generate_erasure
    return render_blank_content_error if @source_text.content.blank?

    options = build_erasure_options
    erasure_content = generate_erasure_content(options)

    @poem = build_erasure_poem(erasure_content, options)

    if @poem.save
      technique_name = options[:is_blackout] ? 'blackout' : 'erasure'
      render_poem_generation_success(technique_name)
    else
      render_poem_save_error
    end
  end

  def build_erasure_options
    method = params[:method] || 'erasure'
    options = { method: method }

    if method == 'erasure'
      options[:num_pages] = (params[:num_pages] || 3).to_i
      options[:words_per_page] = (params[:words_per_page] || 50).to_i
      options[:words_to_keep] = (params[:words_to_keep] || 8).to_i
      options[:is_blackout] = ['true', true].include?(params[:is_blackout])
    end

    options
  end

  def generate_erasure_content(options)
    generator = ErasureGenerator.new(@source_text)
    generator.generate(options)
  end

  def build_erasure_poem(content, options)
    technique_name = options[:is_blackout] ? 'blackout' : 'erasure'
    @source_text.poems.build(
      title: generate_poem_title(@source_text, technique_name),
      content: content,
      technique_used: technique_name
    )
  end

  def generate_snowball
    return render_blank_content_error if @source_text.content.blank?

    options = build_snowball_options
    snowball_content = generate_snowball_content(options)

    @poem = build_snowball_poem(snowball_content)

    if @poem.save
      render_poem_generation_success('snowball')
    else
      render_poem_save_error
    end
  end

  def generate_mesostic
    return render_blank_content_error if @source_text.content.blank?

    options = build_mesostic_options
    mesostic_content = generate_mesostic_content(options)

    @poem = build_mesostic_poem(mesostic_content)

    if @poem.save
      render_poem_generation_success('mesostic')
    else
      render_poem_save_error
    end
  end

  def build_snowball_options
    method = params[:method] || 'snowball'
    options = { method: method }

    if method == 'snowball'
      options[:num_lines] = (params[:num_lines] || 10).to_i
      options[:min_word_length] = (params[:min_word_length] || 1).to_i
    end

    options
  end

  def build_mesostic_options
    method = params[:method] || 'mesostic'
    options = { method: method }

    options[:spine_word] = params[:spine_word] if method == 'mesostic'

    options
  end

  def generate_snowball_content(options)
    generator = SnowballGenerator.new(@source_text)
    generator.generate(options)
  end

  def generate_mesostic_content(options)
    generator = MesosticGenerator.new(@source_text)
    generator.generate(options)
  end

  def build_snowball_poem(content)
    @source_text.poems.build(
      title: generate_poem_title(@source_text, 'snowball'),
      content: content,
      technique_used: 'snowball'
    )
  end

  def build_mesostic_poem(content)
    @source_text.poems.build(
      title: generate_poem_title(@source_text, 'mesostic'),
      content: content,
      technique_used: 'mesostic'
    )
  end

  private

  def set_poem
    @poem = Poem.find(params[:id])
  end

  def set_source_text
    @source_text = SourceText.find(params[:id])
  end

  def poem_params
    params.require(:poem).permit(:title, :content, :technique_used, :source_text_id)
  end

  def generate_poem_title(source_text, technique)
    base_title = source_text.title.split.first(3).join(' ')
    timestamp = Time.current.strftime('%m/%d %H:%M')
    technique_label = technique.capitalize.tr('_', '-')
    "#{technique_label}: #{base_title} (#{timestamp})"
  end
end
