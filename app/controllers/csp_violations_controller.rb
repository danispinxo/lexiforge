class CspViolationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    Rails.logger.warn "CSP Violation: #{params.inspect}"

    head :no_content
  end
end
