class Api::SourceTextsController < ApiController
  before_action :set_source_text, only: [:show]

  def index
    @source_texts = SourceText.all
    render json: @source_texts, each_serializer: SourceTextSerializer
  end

  def show
    render json: @source_text, serializer: SourceTextDetailSerializer
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
        }, status: :unprocessable_content
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
