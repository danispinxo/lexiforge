class ApiController < ApplicationController
  include Devise::Controllers::Helpers
  include Devise::Controllers::SignInOut

  protect_from_forgery with: :null_session
  before_action :set_cors_headers

  def handle_options_request
    head :ok
  end

  private

  def current_api_user
    return @current_api_user if defined?(@current_api_user)

    @current_api_user = warden.user(:user)
    Rails.logger.info "=== AUTH DEBUG: current_api_user = #{@current_api_user&.email || 'nil'}"
    @current_api_user
  end

  def current_admin_user
    return @current_admin_user if defined?(@current_admin_user)

    @current_admin_user = warden.user(:admin_user)
    Rails.logger.info "=== AUTH DEBUG: current_admin_user = #{@current_admin_user&.email || 'nil'}"
    @current_admin_user
  end

  def authenticate_any_user!
    return if current_api_user || current_admin_user

    render json: {
      success: false,
      message: 'Authentication required'
    }, status: :unauthorized
  end

  def authenticate_admin!
    return if current_admin_user || current_api_user&.admin?

    render json: {
      success: false,
      message: 'Admin access required'
    }, status: :forbidden
  end

  def set_cors_headers
    allowed_origins = ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3001').split(',')
    origin = request.headers['Origin']

    response.headers['Access-Control-Allow-Origin'] = origin if allowed_origins.include?(origin)

    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
  end
end
