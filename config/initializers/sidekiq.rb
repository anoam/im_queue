require 'redis'
require 'sidekiq'

redis_conf = YAML.load_file(Rails.root.join('config/redis.yml').to_s)[Rails.env]

Sidekiq.configure_client do |config|
  config.redis = { url: redis_conf.fetch("connection_string") }
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_conf.fetch("connection_string") }
end

