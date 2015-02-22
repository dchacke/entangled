# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'entangled/version'

Gem::Specification.new do |spec|
  spec.name          = "entangled"
  spec.version       = Entangled::VERSION
  spec.authors       = ["Dennis Charles Hackethal"]
  spec.email         = ["dennis.hackethal@gmail.com"]
  spec.summary       = %q{Makes Rails real time through websockets.}
  spec.description   = %q{Makes Rails real time through websockets. Check out the JavaScript counterpart for the front end.}
  spec.homepage      = "https://github.com/so-entangled/rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = Dir["spec/**/*"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec-rails', '~> 3.2'
  spec.add_development_dependency 'sqlite3'
  spec.add_dependency 'tubesock', '~> 0.2'
  spec.add_dependency 'rails', '~> 4.2'
end
