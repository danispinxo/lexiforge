class Api::V1::SourceTextsController < ApplicationController
  before_action :set_source_text, only: [:show]

  def index
    @source_texts = SourceText.all
    render json: @source_texts.map do |text|
      {
        id: text.id,
        title: text.title,
        gutenberg_id: text.gutenberg_id,
        word_count: text.content&.split&.length || 0,
        content_preview: text.content&.truncate(200) || '',
        created_at: text.created_at
      }
    end
  end

  def show
    render json: {
      id: @source_text.id,
      title: @source_text.title,
      gutenberg_id: @source_text.gutenberg_id,
      content: @source_text.content,
      word_count: @source_text.content&.split&.length || 0,
      created_at: @source_text.created_at,
      poems_count: @source_text.poems.count
    }
  end

  def import_from_gutenberg
    if params[:gutenberg_id].present?
      service = ProjectGutenbergService.new
      source_text = service.import_text(params[:gutenberg_id])

      if source_text.persisted?
        render json: {
          success: true,
          message: "Successfully imported '#{source_text.title}'",
          source_text: {
            id: source_text.id,
            title: source_text.title,
            gutenberg_id: source_text.gutenberg_id
          }
        }
      else
        render json: {
          success: false,
          message: "Failed to import text: #{source_text.errors.full_messages.join(', ')}"
        }, status: :unprocessable_entity
      end
    else
      render json: {
        success: false,
        message: 'Please provide a valid Gutenberg ID'
      }, status: :bad_request
    end
  end

  private

  def set_source_text
    @source_text = SourceText.find(params[:id])
  end
end
