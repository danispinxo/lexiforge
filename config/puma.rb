max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 2)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS', max_threads_count)
threads min_threads_count, max_threads_count

if ENV['RAILS_ENV'] == 'production'
  require 'concurrent-ruby'
  worker_count = ENV.fetch('WEB_CONCURRENCY', 2)
  workers worker_count if worker_count > 1
end

worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

port ENV.fetch('PORT', 3000)

environment ENV.fetch('RAILS_ENV', 'development')

pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

plugin :tmp_restart
