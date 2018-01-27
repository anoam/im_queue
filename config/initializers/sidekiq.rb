require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = REDIS_POOL
end

Sidekiq.configure_server do |config|
  config.redis = REDIS_POOL
end

