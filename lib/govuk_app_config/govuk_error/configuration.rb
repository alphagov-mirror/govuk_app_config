require "govuk_app_config/govuk_error/govuk_data_sync"

module GovukError
  class Configuration < SimpleDelegator
    attr_accessor :data_sync_excluded_exceptions

    def initialize(_raven_configuration)
      super
      self.should_capture = data_sync_closure
      self.data_sync_excluded_exceptions = []
    end

    def should_capture=(closure)
      combined = lambda do |error_or_event|
        (data_sync_closure.call(error_or_event) && closure.call(error_or_event))
      end

      super(combined)
    end

  private

    def data_sync_closure
      -> (error_or_event) {
        return true if data_sync_excluded_exceptions.empty? || !ENV["GOVUK_DATA_SYNC_PERIOD"]

        data_sync = GovukDataSync.new(ENV["GOVUK_DATA_SYNC_PERIOD"])
        return true unless data_sync.in_progress?

        Raven::Utils::ExceptionCauseChain.exception_to_array(error_or_event).none? do |cause|
          data_sync_excluded_exceptions.include?(cause.class.to_s)
        end
      }
    end
  end
end
