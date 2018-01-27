require 'redis'

conf = YAML.load_file(Rails.root.join('config/redis.yml').to_s)[Rails.env]
Redis.current = Redis::Namespace.new(conf.fetch("namespace", Rails.env), redis: Redis.new(url: conf.fetch("connection_string")))
