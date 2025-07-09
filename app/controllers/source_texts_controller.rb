class SourceTextsController < ApplicationController
  before_action :set_source_text, only: [:show]

  def index
    @source_texts = SourceText.all
  end

  def show
  end

  def import_from_gutenberg
    if params[:gutenberg_id].present?
      service = ProjectGutenbergService.new
      source_text = service.import_text(params[:gutenberg_id])
      
      if source_text.persisted?
        redirect_to source_texts_path, notice: "Successfully imported '#{source_text.title}'"
      else
        redirect_to source_texts_path, alert: "Failed to import text: #{source_text.errors.full_messages.join(', ')}"
      end
    else
      redirect_to source_texts_path, alert: "Please provide a valid Gutenberg ID"
    end
  end

  private

  def set_source_text
    @source_text = SourceText.find(params[:id])
  end
end
