class Api::SourceTextsController < ApiController
  before_action :authenticate_any_user!, only: [:my_source_texts, :import_from_gutenberg]
  before_action :set_source_text, only: [:show]

  def index
    @source_texts = SourceText.public_texts.includes(:owner)
    render json: @source_texts, each_serializer: SourceTextSerializer
  end

  def show
    render json: @source_text, serializer: SourceTextDetailSerializer
  end

  def my_source_texts
    current_user = current_api_user || current_admin_user
    @source_texts = SourceText.for_owner(current_user).includes(:owner)
    render json: @source_texts, each_serializer: SourceTextSerializer
  end

  def import_from_gutenberg
    if params[:gutenberg_id].present?
      service = ProjectGutenbergService.new
      source_text = service.import_text(params[:gutenberg_id])

      if source_text.persisted?
        current_user = current_api_user || current_admin_user
        if current_user
          is_public = current_admin_user ? (params[:is_public] != 'false') : false
          source_text.update(owner: current_user, is_public: is_public)
        end

        render json: {
          success: true,
          message: "Successfully imported '#{source_text.title}'",
          source_text: {
            id: source_text.id,
            title: source_text.title,
            gutenberg_id: source_text.gutenberg_id,
            is_public: source_text.is_public
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
