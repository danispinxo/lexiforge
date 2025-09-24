class Api::SourceTextsController < ApiController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_any_user!, only: %i[my_source_texts import_from_gutenberg create_custom download]
  before_action :set_source_text, only: %i[show download]

  def index
    @source_texts = build_source_texts_query(SourceText.public_texts)
    render_paginated_source_texts
  end

  def show
    render json: @source_text, serializer: SourceTextDetailSerializer
  end

  def my_source_texts
    current_user = current_api_user || current_admin_user
    @source_texts = build_source_texts_query(SourceText.for_owner(current_user))
    render_paginated_source_texts
  end

  def import_from_gutenberg
    return render_missing_gutenberg_id if params[:gutenberg_id].blank?

    service = ProjectGutenbergService.new
    source_text = service.import_text(params[:gutenberg_id])

    return render_import_error(source_text) unless source_text.persisted?

    update_source_text_ownership(source_text)
    render_import_success(source_text)
  end

  def create_custom
    return render_missing_required_fields unless valid_custom_params?
    return render_content_too_short unless content_length_valid?
    return render_content_too_long unless content_length_reasonable?

    current_user = current_api_user || current_admin_user
    return render_unauthorized unless current_user

    source_text = build_custom_source_text(current_user)

    if source_text.save
      render_custom_upload_success(source_text)
    else
      render_upload_error(source_text)
    end
  end

  def download
    filename = sanitize_filename("#{@source_text.title}.txt")

    send_data @source_text.content,
              filename: filename,
              type: 'text/plain; charset=utf-8',
              disposition: 'attachment'
  end

  private

  def set_source_text
    @source_text = SourceText.find(params[:id])
  end

  def apply_search(scope, search_term)
    return scope if search_term.blank?

    scope.where(
      'title ILIKE ? OR content ILIKE ?',
      "%#{search_term}%", "%#{search_term}%"
    )
  end

  def build_source_texts_query(base_scope)
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    scope = base_scope.includes(:owner)
    scope = apply_search(scope, params[:search])
    scope = apply_sorting(scope, params[:sort_by], params[:sort_direction])
    scope.page(page).per(per_page)
  end

  def render_paginated_source_texts
    render json: {
      source_texts: ActiveModel::Serializer::CollectionSerializer.new(
        @source_texts, serializer: SourceTextSerializer
      ),
      pagination: pagination_metadata
    }
  end

  def pagination_metadata
    {
      current_page: @source_texts.current_page,
      total_pages: @source_texts.total_pages,
      total_count: @source_texts.total_count,
      per_page: @source_texts.limit_value,
      next_page: @source_texts.next_page,
      prev_page: @source_texts.prev_page
    }
  end

  def apply_sorting(scope, sort_by, sort_direction)
    sort_by ||= 'created_at'
    sort_direction ||= 'desc'

    sort_direction = 'desc' unless %w[asc desc].include?(sort_direction.downcase)

    case sort_by
    when 'title'
      scope.order("title #{sort_direction}")
    when 'word_count'
      scope.order("LENGTH(content) #{sort_direction}")
    when 'created_at'
      scope.order("created_at #{sort_direction}")
    when 'gutenberg_id'
      scope.order("gutenberg_id #{sort_direction} NULLS LAST")
    else
      scope.order(created_at: :desc)
    end
  end

  def render_missing_gutenberg_id
    render json: {
      success: false,
      message: 'Please provide a valid Gutenberg ID'
    }, status: :bad_request
  end

  def render_import_error(source_text)
    render json: {
      success: false,
      message: "Failed to import text: #{source_text.errors.full_messages.join(', ')}"
    }, status: :unprocessable_content
  end

  def update_source_text_ownership(source_text)
    current_user = current_api_user || current_admin_user
    return unless current_user

    is_public = source_text_should_be_public?
    source_text.update(owner: current_user, is_public: is_public)
  end

  def source_text_should_be_public?
    current_admin_user ? (params[:is_public] != 'false') : false
  end

  def render_import_success(source_text)
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
  end

  def render_missing_required_fields
    render json: {
      success: false,
      message: 'Please provide both title and content for your custom source text'
    }, status: :bad_request
  end

  def render_unauthorized
    render json: {
      success: false,
      message: 'You must be logged in to upload custom source texts'
    }, status: :unauthorized
  end

  def render_custom_upload_success(source_text)
    render json: {
      success: true,
      message: "Successfully uploaded '#{source_text.title}'",
      source_text: {
        id: source_text.id,
        title: source_text.title,
        gutenberg_id: source_text.gutenberg_id,
        is_public: source_text.is_public
      }
    }
  end

  def render_content_too_short
    render json: {
      success: false,
      message: 'Content must be at least 100 characters long'
    }, status: :bad_request
  end

  def render_content_too_long
    render json: {
      success: false,
      message: 'Content must be less than 1,000,000 characters long'
    }, status: :bad_request
  end

  def render_upload_error(source_text)
    render json: {
      success: false,
      message: "Failed to upload text: #{source_text.errors.full_messages.join(', ')}"
    }, status: :unprocessable_content
  end

  def valid_custom_params?
    params[:title].present? && params[:content].present?
  end

  def content_length_valid?
    params[:content].strip.length >= 100
  end

  def content_length_reasonable?
    params[:content].strip.length <= 1_000_000
  end

  def build_custom_source_text(user)
    SourceText.new(
      title: params[:title].strip,
      content: params[:content].strip,
      gutenberg_id: nil,
      owner: user,
      is_public: false
    )
  end

  def sanitize_filename(filename)
    # Remove or replace invalid characters for filenames
    filename.gsub(/[^\w\-_.]/, '_').squeeze('_')
  end
end
