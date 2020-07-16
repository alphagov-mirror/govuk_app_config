require "statsd"
require "forwardable"

module GovukStatsd
  extend SingleForwardable
  def_delegators :client, :increment, :decrement, :count, :time, :timing,
    :gauge, :set, :batch

  def self.client
    @statsd_client ||= begin
      statsd_client = ::Statsd.new(ENV["STATSD_HOST"] || "localhost", 8125, ENV["STATSD_PROTOCOL"]&.to_sym || :udp)
      statsd_client.namespace = ENV["GOVUK_STATSD_PREFIX"].to_s
      statsd_client
    end
  end
end
