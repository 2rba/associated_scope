# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "associated_scope/version"

Gem::Specification.new do |spec|
  spec.name          = "associated_scope"
  spec.version       = AssociatedScope::VERSION
  spec.authors       = ["Serg Tyatin"]
  spec.email         = ["700@2rba.com"]

  spec.summary       = %q{Preloadable ActiveRecord scope}
  spec.description   = %q{ActiveRecord preloads works only with model associations, this gem allow to create dynamic preloadable scope. That helps to solve N+1 query problem.}
  spec.homepage      = "https://github.com/2rba/associated_scope"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "factory_bot", "~> 6.1.0"
  spec.add_development_dependency "pry-byebug"
end
