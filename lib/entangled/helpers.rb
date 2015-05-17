module Entangled
  module Helpers
    # Get Redis that user might be using or instantiate
    # a new one
    def redis
      Redis.new
    end
  end
end
