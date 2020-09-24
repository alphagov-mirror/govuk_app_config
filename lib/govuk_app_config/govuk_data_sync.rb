require "time"

class GovukDataSync
  attr_reader :from, :to

  def initialize(govuk_data_sync_period)
    parts = govuk_data_sync_period&.split("-")
    @from, @to = parts.map { |time| Time.parse(time) } if parts&.count == 2
  rescue ArgumentError
    # At least one of the parts was malformed. Leave @from/@to as false.
  end

  def in_progress?
    from.present? && to.present? && in_time_range?(from, to)
  end

private

  def in_time_range?(from, to)
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
