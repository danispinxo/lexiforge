Rails.application.configure do
  config.force_ssl = true if Rails.env.production?
  
  config.middleware.use Rack::Deflater
end

class SecurityHeadersMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    
    headers['X-Content-Type-Options'] = 'nosniff'
    headers['X-Frame-Options'] = 'DENY'
    headers['X-XSS-Protection'] = '1; mode=block'
    headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    headers['Permissions-Policy'] = 'geolocation=(), microphone=(), camera=()'
    
    if Rails.env.production?
      headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains; preload'
    end
    
    [status, headers, response]
  end
end

Rails.application.config.middleware.use SecurityHeadersMiddleware
