# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/auth0_shipper/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-auth0_shipper'
  spec.version       = Fastlane::Auth0Shipper::VERSION
  spec.author        = %q{Hernan Zalazar}
  spec.email         = %q{hernan.zalazar@gmail.com}

  spec.summary       = %q{OSS libraries release process for Auth0}
  spec.homepage      = "https://github.com/auth0/fastlane-plugin-auth0_shipper"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency 'semantic',  '~> 1.5'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 2.96.1'
end
