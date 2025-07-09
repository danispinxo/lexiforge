class PoemsController < ApplicationController
  before_action :set_poem, only: [:show, :edit, :update, :destroy]
  before_action :set_source_text, only: [:generate_cut_up]

  def index
    @poems = Poem.includes(:source_text).order(created_at: :desc)
  end

  def show
    @source_text = @poem.source_text
  end

  def new
    @poem = Poem.new
    @source_texts = SourceText.all
  end

  def create
    @poem = Poem.new(poem_params)
    
    if @poem.save
      redirect_to @poem, notice: 'Poem was successfully created.'
    else
      @source_texts = SourceText.all
      render :new, status: :unprocessable_entity
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

    # Generate the cut-up content with medium size, line-based method
    generator = CutUpGenerator.new(@source_text)
    cut_up_content = generator.generate(method: 'lines', size: 'medium')

    # Create and save the poem
    @poem = @source_text.poems.build(
      title: generate_poem_title(@source_text),
      content: cut_up_content,
      technique_used: "cut-up"
    )

    if @poem.save
      redirect_to @poem, notice: "Cut-up poem successfully generated from '#{@source_text.title}'!"
    else
      redirect_to @source_text, alert: "Failed to generate poem: #{@poem.errors.full_messages.join(', ')}"
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
