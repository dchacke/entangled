require 'spec_helper'

# Make method directly accessible on module
# to test it
Entangled::Helpers.send :module_function, :redis

# Constant REDIS and global variable $redis
# are unset repeatedly just in case the test
# order set them before running another test
# since the helper method #redis checks
# if these variables are defined and present

RSpec.describe Entangled::Helpers do
  context '$redis defined' do
    # Mock a redis client
    let(:global_redis) do
      mock("redis").tap do |redis|
        redis.stubs(:publish)
        redis.stubs(:client).returns(redis)

        # Set an arbitrary option
        redis.stubs(:options).returns({ global: true })
      end
    end

    it 'uses $redis' do
      # Remove constant if it exists
      Object.send :remove_const, :REDIS rescue nil

      # Assign mocked redis client to global variable
      $redis = global_redis

      # Check if the helper automatically uses that global variable
      expect(Entangled::Helpers.redis.client.options[:global]).to be_truthy
    end
  end

  context 'REDIS defined' do
    # Mock a redis client
    let(:constant_redis) do
      mock("redis").tap do |redis|
        redis.stubs(:publish)
        redis.stubs(:client).returns(redis)

        # Set an arbitrary option
        redis.stubs(:options).returns({ constant: true })
      end
    end

    it 'uses REDIS' do
      # Unset global variable
      $redis = nil

      # Assign mocked redis client to global variable
      REDIS = constant_redis

      # Check if the helper automatically uses that constant
      expect(Entangled::Helpers.redis.client.options[:constant]).to be_truthy
    end
  end

  context 'none defined' do
    it 'uses its own default standards' do
      # Unset global variable
      $redis = nil

      # Remove constant if it exists
      Object.send :remove_const, :REDIS rescue nil

      # Check if helper automatically uses default options for Redis
      expect(Entangled::Helpers.redis.client.options).to eq Redis.new.client.options
    end
  end
end
