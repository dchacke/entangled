ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'bourne'
require 'byebug'
# require 'factory_girl_rails'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# For bourne mocking
RSpec.configure do |config|
  config.mock_with :mocha
end
