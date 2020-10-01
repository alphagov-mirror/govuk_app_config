require "govuk_app_config/version"
require "govuk_app_config/govuk_statsd"
require "govuk_app_config/govuk_error"
require "govuk_app_config/govuk_healthcheck"
# This require is deprecated and should be removed on next major version bump
# and should be required by applications directly.
require "govuk_app_config/govuk_unicorn"
require "govuk_app_config/govuk_error/configure_defaults"

GovukError.configure do |config|
  GovukError::ConfigureDefaults.new(config)
end

if defined?(Rails)
  require "govuk_app_config/govuk_logging"
  require "govuk_app_config/govuk_content_security_policy"
  require "govuk_app_config/railtie"
end
