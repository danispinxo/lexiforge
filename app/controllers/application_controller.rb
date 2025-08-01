class ApplicationController < ActionController::API
  before_action :set_cors_headers

  def handle_options_request
    head :ok
  end

  private

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3001'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
  end
end
