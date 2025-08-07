class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.path.start_with?('/api') }

  def handle_options_request
    if request.path.start_with?('/api')
      allowed_origins = ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3001').split(',')
      origin = request.headers['Origin']

      response.headers['Access-Control-Allow-Origin'] = origin if allowed_origins.include?(origin)

      response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
      response.headers['Access-Control-Allow-Credentials'] = 'true'
    end
    head :ok
  end
end

class ApiController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :set_cors_headers

  def handle_options_request
    head :ok
  end

  private

  def set_cors_headers
    allowed_origins = ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3001').split(',')
    origin = request.headers['Origin']

    response.headers['Access-Control-Allow-Origin'] = origin if allowed_origins.include?(origin)

    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
  end
end
