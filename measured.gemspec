# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'measured/version'

Gem::Specification.new do |spec|
  spec.name          = "measured"
  spec.version       = Measured::VERSION
  spec.authors       = ["Kevin McPhillips", "Jason Gedge", "Javier Honduvilla Coto"]
  spec.email         = ["gems@shopify.com"]
  spec.summary       = %q{Encapsulate measurements with their units in Ruby}
  spec.description   = %q{Wrapper objects which encapsulate measurements and their associated units in Ruby.}
  spec.homepage      = "https://github.com/Shopify/measured"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0.0"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 5.2"

  spec.add_development_dependency "rake", "> 10.0"
  spec.add_development_dependency "minitest", "> 5.5.1"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "mocha", ">= 1.4.0"
  spec.add_development_dependency "pry"
end
