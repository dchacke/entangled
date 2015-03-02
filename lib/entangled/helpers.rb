module Entangled
  module Helpers
    # Get Redis that user might be using or instantiate
    # a new one
    def redis
      if defined?($redis)
        $redis
      elsif defined?(REDIS)
        REDIS
      else
        Redis.new
      end
    end
  end
end
