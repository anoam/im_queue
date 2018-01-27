require 'redis'
require 'connection_pool'

conf = YAML.load_file(Rails.root.join('config/redis.yml').to_s)[Rails.env]

REDIS_POOL = ConnectionPool.new(size: conf.fetch("pool", 27)) do
  Redis::Namespace.new(conf.fetch("namespace", Rails.env), redis: Redis.new(url: conf.fetch("connection_string")))
end
