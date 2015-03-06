module Entangled
  module Helpers
    # Get Redis that user might be using or instantiate
    # a new one
    def redis
      if defined?($redis) && $redis
        Redis.new($redis.client.options)
      elsif defined?(REDIS) && REDIS
        Redis.new(REDIS.client.options)
      else
        Redis.new
      end
    end
  end
end
