Rails.application.configure do
  config.force_ssl = true if Rails.env.production?
  
  config.middleware.use Rack::Deflater
  
  config.middleware.use(Rack::Protection, 
    use: %i[
      escaped_params
      form_token
      frame_options
      path_traversal
      remote_referrer
      remote_token
      session_hijacking
      xss_header
    ],
    frame_options: :deny,
    xss_header: :block,
    except: lambda { |env| env['PATH_INFO'].start_with?('/api') }
  )
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
