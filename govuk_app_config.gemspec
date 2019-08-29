# coding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "govuk_app_config/version"

Gem::Specification.new do |spec|
  spec.name          = "govuk_app_config"
  spec.version       = GovukAppConfig::VERSION
  spec.authors       = ["GOV.UK Dev"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary       = "Base configuration for GOV.UK applications"
  spec.description   = "Base configuration for GOV.UK applications"
  spec.homepage      = "https://github.com/alphagov/govuk_app_config"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency "logstasher", ">= 1.2.2", "< 1.4.0"
  spec.add_dependency "sentry-raven", ">= 2.7.1", "< 2.12.0"
  spec.add_dependency "statsd-ruby", "~> 1.4.0"
  spec.add_dependency "unicorn", ">= 5.4", "< 5.6"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "climate_control"
  spec.add_development_dependency "rails", "~> 5"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.8.0"
  spec.add_development_dependency "rspec-its", "~> 1.3.0"
  spec.add_development_dependency "webmock"
end
