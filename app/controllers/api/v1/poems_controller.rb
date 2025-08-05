class Api::V1::PoemsController < ApplicationController
  before_action :set_poem, only: %i[show edit update destroy]
  before_action :set_source_text, only: [:generate_cut_up, :generate_erasure]

  def index
    @poems = Poem.includes(:source_text).order(created_at: :desc)
    render json: @poems.map do |poem|
      {
        id: poem.id,
        title: poem.title,
        technique_used: poem.technique_used,
        content_preview: poem.content&.truncate(200) || '',
        source_text: if poem.source_text
                       {
                         id: poem.source_text.id,
                         title: poem.source_text.title
                       }
                     end,
        created_at: poem.created_at
      }
    end
  end

  def show
    render json: {
      id: @poem.id,
      title: @poem.title,
      content: @poem.content,
      technique_used: @poem.technique_used,
      source_text: {
        id: @poem.source_text.id,
        title: @poem.source_text.title
      },
      created_at: @poem.created_at
    }
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
      redirect_to @poem, notice: 'Poem was successfully updated.'
    else
      @source_texts = SourceText.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @poem.destroy
    redirect_to poems_url, notice: 'Poem was successfully deleted.'
  end

  def generate_cut_up
    if @source_text.content.blank?
      redirect_to @source_text, alert: 'Cannot generate poem: source text has no content.'
      return
    end

    generator = CutUpGenerator.new(@source_text)
    method = params[:method] || 'cut_up'

    options = { method: method }

    if method == 'cut_up'
      options[:num_lines] = params[:num_lines] || 12
      options[:words_per_line] = params[:words_per_line] || 6
    else
      options[:size] = params[:size] || 'medium'
    end

    cut_up_content = generator.generate(options)

    # Create and save the poem
    @poem = @source_text.poems.build(
      title: generate_poem_title(@source_text, 'cutup'),
      content: cut_up_content,
      technique_used: 'cutup'
    )

    if @poem.save
      render json: {
        success: true,
        message: "Cut-up poem successfully generated from '#{@source_text.title}'!",
        poem: {
          id: @poem.id,
          title: @poem.title,
          content: @poem.content,
          technique_used: @poem.technique_used,
          source_text_id: @poem.source_text_id
        }
      }
    else
      render json: {
        success: false,
        message: "Failed to generate poem: #{@poem.errors.full_messages.join(', ')}"
      }, status: :unprocessable_entity
    end
  end

  def generate_erasure
    if @source_text.content.blank?
      redirect_to @source_text, alert: 'Cannot generate poem: source text has no content.'
      return
    end

    generator = ErasureGenerator.new(@source_text)
    method = params[:method] || 'erasure'

    options = { method: method }

    if method == 'erasure'
      options[:num_pages] = params[:num_pages] || 3
      options[:words_per_page] = params[:words_per_page] || 50
      options[:words_to_keep] = params[:words_to_keep] || 8
    end

    erasure_content = generator.generate(options)

    @poem = @source_text.poems.build(
      title: generate_poem_title(@source_text, 'erasure'),
      content: erasure_content,
      technique_used: 'erasure'
    )

    if @poem.save
      render json: {
        success: true,
        message: "Erasure poem successfully generated from '#{@source_text.title}'!",
        poem: {
          id: @poem.id,
          title: @poem.title,
          content: @poem.content,
          technique_used: @poem.technique_used,
          source_text_id: @poem.source_text_id
        }
      }
    else
      render json: {
        success: false,
        message: "Failed to generate poem: #{@poem.errors.full_messages.join(', ')}"
      }, status: :unprocessable_entity
    end
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
    technique_label = technique.capitalize.gsub('_', '-')
    "#{technique_label}: #{base_title} (#{timestamp})"
  end
end
