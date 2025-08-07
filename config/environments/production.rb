require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = true
  config.active_storage.service = :local
  config.force_ssl = true

  config.logger = ActiveSupport::Logger.new($stdout)
                                       .tap  { |logger| logger.formatter = Logger::Formatter.new }
                                       .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [:request_id]
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false

  # Database configuration
  config.active_record.database_url = ENV['DATABASE_URL'] if ENV['DATABASE_URL']

  # Action Cable configuration
  config.action_cable.url = ENV.fetch('ACTION_CABLE_URL', nil)
  config.action_cable.allowed_request_origins = ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3001').split(',')
end
