require "time"

class DefaultConfiguration
  def initialize(config)
    config.before_send = proc { |e|
      GovukStatsd.increment("errors_occurred")
      GovukStatsd.increment("error_types.#{e.class.name.demodulize.underscore}")
      e
    }

    config.silence_ready = !Rails.env.production? if defined?(Rails)

    config.excluded_exceptions = [
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
    config.inspect_exception_causes_for_exclusion = true

    config.transport_failure_callback = proc {
      GovukStatsd.increment("error_reports_failed")
    }

    config.should_capture = lambda do |error_or_event|
      data_sync_ignored_error = error_or_event.is_a?(PG::Error) ||
        (error_or_event.respond_to?(:cause) && error_or_event.cause.is_a?(PG::Error))
      data_sync_time = in_data_sync?(ENV["GOVUK_DATA_SYNC_PERIOD"])

      !(data_sync_ignored_error && data_sync_time)
    end
  end

private

  def in_data_sync?(time_range)
    from, to = time_range.split("-").map { |time| Time.parse(time) }
    hour_is_in_range = Time.now.hour >= from.hour || Time.now.hour <= to.hour
    minute_is_in_range = if Time.now.hour == from.hour
                           Time.now.min >= from.min
                         elsif Time.now.hour == to.hour
                           Time.now.min <= to.min
                         else
                           true
                         end
    hour_is_in_range && minute_is_in_range
  end
end
