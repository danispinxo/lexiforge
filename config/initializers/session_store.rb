Rails.application.config.session_store :cookie_store, 
  key: '_lexiforge_session',
  secure: Rails.env.production?,
  httponly: true,
  same_site: Rails.env.production? ? :none : :lax,
  expire_after: 2.weeks
