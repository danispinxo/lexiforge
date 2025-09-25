class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  throttle('logins/email', limit: 5, period: 20.minutes) do |req|
    if req.path == '/api/users/sign_in' && req.post?
      req.params['email'].presence&.downcase
    end
  end

  throttle('logins/ip', limit: 20, period: 20.minutes) do |req|
    if req.path == '/api/users/sign_in' && req.post?
      req.ip
    end
  end

  throttle('registrations/ip', limit: 5, period: 1.hour) do |req|
    if req.path == '/api/users' && req.post?
      req.ip
    end
  end

  throttle('password_resets/email', limit: 3, period: 1.hour) do |req|
    if req.path == '/api/users/password' && req.post?
      req.params['email'].presence&.downcase
    end
  end

  throttle('api/ip', limit: 300, period: 5.minutes) do |req|
    if req.path.start_with?('/api/')
      req.ip
    end
  end

  blocklist('block suspicious IPs') do |req|
    req.user_agent =~ /curl|wget|python|ruby|java|php/i && 
    !req.path.start_with?('/api/') # Allow legitimate API usage
  end

  self.throttled_responder = lambda do |env|
    match_data = env['rack.attack.match_data']
    now = match_data[:epoch_time]
    
    headers = {
      'Content-Type' => 'application/json',
      'Retry-After' => match_data[:period].to_s,
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + match_data[:period]).to_s
    }
    
    body = {
      success: false,
      message: 'Rate limit exceeded. Please try again later.',
      retry_after: match_data[:period]
    }.to_json
    
    [429, headers, [body]]
  end

  self.blocklisted_responder = lambda do |env|
    [403, {'Content-Type' => 'application/json'}, [{
      success: false,
      message: 'Forbidden'
    }.to_json]]
  end
end

Rails.application.config.middleware.use Rack::Attack
