# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'entangled/version'

Gem::Specification.new do |s|
  s.name          = "entangled"
  s.version       = Entangled::VERSION
  s.authors       = ["Dennis Charles Hackethal"]
  s.email         = ["dennis.hackethal@gmail.com"]
  s.summary       = %q{Makes Rails real time through websockets.}
  s.description   = %q{Makes Rails real time through websockets as a gem in the backend and as an Angular library in the front end.}
  s.homepage      = "https://github.com/dchacke/entangled"
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = `git ls-files -z spec`.split("\x0")
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec-rails', '~> 3.2'
  s.add_development_dependency 'shoulda-matchers', '~> 2.6'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'byebug', '~> 3.5'
  s.add_development_dependency 'bourne', '~> 1.6'
  s.add_development_dependency 'puma', '~> 2.11'
  s.add_dependency 'tubesock', '~> 0.2'
  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'redis', '~> 3.2'
end
