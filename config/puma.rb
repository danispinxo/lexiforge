max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 2).to_i
min_threads_count = ENV.fetch('RAILS_MIN_THREADS', max_threads_count).to_i
threads min_threads_count, max_threads_count

if ENV['RAILS_ENV'] == 'production'
  require 'concurrent-ruby'
  worker_count = ENV.fetch('WEB_CONCURRENCY', 2).to_i
  workers worker_count if worker_count > 1
end

worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

port ENV.fetch('PORT', 3000).to_i

environment ENV.fetch('RAILS_ENV', 'development')

pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

plugin :tmp_restart
