class Api::V1::PoemsController < ApplicationController
  before_action :set_poem, only: [:show, :edit, :update, :destroy]
  before_action :set_source_text, only: [:generate_cut_up]

  def index
    @poems = Poem.includes(:source_text).order(created_at: :desc)
    render json: @poems.map do |poem|
      {
        id: poem.id,
        title: poem.title,
        technique_used: poem.technique_used,
        content_preview: poem.content&.truncate(200) || '',
        source_text: poem.source_text ? {
          id: poem.source_text.id,
          title: poem.source_text.title
        } : nil,
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

  def edit
    @source_texts = SourceText.all
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
      redirect_to @source_text, alert: "Cannot generate poem: source text has no content."
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
      title: generate_poem_title(@source_text),
      content: cut_up_content,
      technique_used: "cutup"
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

  def generate_poem_title(source_text)
    base_title = source_text.title.split.first(3).join(' ') # Take first 3 words
    timestamp = Time.current.strftime("%m/%d %H:%M")
    "Cut-Up: #{base_title} (#{timestamp})"
  end
end
