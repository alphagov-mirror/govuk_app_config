require "spec_helper"
require "rails"
require "govuk_app_config/govuk_error/govuk_data_sync"

RSpec.describe GovukError::GovukDataSync do
  describe ".initialize" do
    it "raises an exception if data sync time period is not defined" do
      expect { GovukError::GovukDataSync.new(nil) }.to raise_error(GovukError::GovukDataSync::MissingDataSyncPeriod)
    end

    it "raises an exception if data sync time period is malformed" do
      invalid_values = [
        "foo",
        "22:00",
        "10:10-10:10-10:10",
        "3:00-fish",
      ]
      invalid_values.each do |val|
        expect { GovukError::GovukDataSync.new(val) }.to raise_error(
          GovukError::GovukDataSync::MalformedDataSyncPeriod,
          "\"#{val}\" is not a valid value (should be of form '22:00-03:00').",
        )
      end
    end
  end

  describe ".in_progress?" do
    it "returns false if we are outside of the time range" do
      data_sync = GovukError::GovukDataSync.new("22:30-8:30")
      at(hour: 21) { expect(data_sync.in_progress?).to eq(false) }
      at(hour: 22, min: 29) { expect(data_sync.in_progress?).to eq(false) }
      at(hour: 8, min: 31) { expect(data_sync.in_progress?).to eq(false) }
    end

    it "returns true if we are within the time range" do
      data_sync = GovukError::GovukDataSync.new("22:30-8:30")
      at(hour: 22, min: 30) { expect(data_sync.in_progress?).to eq(true) }
      at(hour: 0) { expect(data_sync.in_progress?).to eq(true) }
      at(hour: 8, min: 30) { expect(data_sync.in_progress?).to eq(true) }
    end
  end

  def at(time)
    travel_to(Time.current.change(time)) do
      yield
    end
  end
end
