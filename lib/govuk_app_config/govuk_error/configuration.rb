require "govuk_app_config/govuk_data_sync"

module GovukError
  class Configuration < SimpleDelegator
    attr_reader :data_sync

    def initialize(_raven_configuration_instance)
      super

      self.current_environment = ENV["SENTRY_CURRENT_ENV"]

      self.before_send = proc { |e|
        GovukStatsd.increment("errors_occurred")
        GovukStatsd.increment("error_types.#{e.class.name.demodulize.underscore}")
        e
      }

      self.silence_ready = !Rails.env.production? if defined?(Rails)

      self.excluded_exceptions = [
        # Default ActionDispatch rescue responses
        "ActionController::RoutingError",
        "AbstractController::ActionNotFound",
        "ActionController::MethodNotAllowed",
        "ActionController::UnknownHttpMethod",
        "ActionController::NotImplemented",
        "ActionController::UnknownFormat",
        "Mime::Type::InvalidMimeType",
        "ActionController::MissingExactTemplate",
        "ActionController::InvalidAuthenticityToken",
        "ActionController::InvalidCrossOriginRequest",
        "ActionDispatch::Http::Parameters::ParseError",
        "ActionController::BadRequest",
        "ActionController::ParameterMissing",
        "Rack::QueryParser::ParameterTypeError",
        "Rack::QueryParser::InvalidParameterError",
        # Default ActiveRecord rescue responses
        "ActiveRecord::RecordNotFound",
        "ActiveRecord::StaleObjectError",
        "ActiveRecord::RecordInvalid",
        "ActiveRecord::RecordNotSaved",
        # Additional items
        "ActiveJob::DeserializationError",
        "CGI::Session::CookieStore::TamperedWithCookie",
        "GdsApi::HTTPIntermittentServerError",
        "GdsApi::TimedOutException",
        "Mongoid::Errors::DocumentNotFound",
        "Sinatra::NotFound",
      ]

      # This will exclude exceptions that are triggered by one of the ignored
      # exceptions. For example, when any exception occurs in a template,
      # Rails will raise a ActionView::Template::Error, instead of the original error.
      self.inspect_exception_causes_for_exclusion = true

      self.transport_failure_callback = proc {
        GovukStatsd.increment("error_reports_failed")
      }

      @data_sync = GovukDataSync.new(ENV["GOVUK_DATA_SYNC_PERIOD"])
      self.should_capture = nil
    end

    def should_capture=(closure)
      if closure.nil?
        super(default_should_capture)
      else
        combined = lambda do |error_or_event|
          (default_should_capture.call(error_or_event) && closure.call(error_or_event))
        end
        super(combined)
      end
    end

  private

    def default_should_capture
      lambda do |error_or_event|
        data_sync_ignored_error = error_or_event.is_a?(PG::Error) ||
          (error_or_event.respond_to?(:cause) && error_or_event.cause.is_a?(PG::Error))

        if !data_sync.in_progress?
          true
        else
          !data_sync_ignored_error
        end
      end
    end
  end
end
