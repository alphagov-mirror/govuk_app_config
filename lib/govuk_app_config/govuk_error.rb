require "sentry-raven"
require "govuk_app_config/govuk_statsd"
require "govuk_app_config/govuk_error/configuration"
require "govuk_app_config/version"

module GovukError
  def self.notify(exception_or_message, args = {})
    # Allow users to use `parameters` as a key like the Airbrake
    # client, allowing easy upgrades.
    args[:extra] ||= {}
    args[:extra].merge!(parameters: args.delete(:parameters))

    args[:tags] ||= {}
    args[:tags][:govuk_app_config_version] = GovukAppConfig::VERSION

    Raven.capture_exception(exception_or_message, args)
  end

  def self.configure
    @configuration ||= Configuration.new(Raven.configuration)
    yield @configuration
  end
end
