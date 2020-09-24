require "spec_helper"
require "rails"
require "govuk_app_config/govuk_data_sync"

RSpec.describe GovukDataSync do
  describe ".in_progress?" do
    it "returns false if data sync time period is not defined" do
      expect(GovukDataSync.new(nil).in_progress?).to eq(false)
    end

    it "returns false if data sync time period is malformed" do
      expect(GovukDataSync.new("foo").in_progress?).to eq(false)
      expect(GovukDataSync.new("22:00").in_progress?).to eq(false)
      expect(GovukDataSync.new("10:10-10:10-10:10").in_progress?).to eq(false)
      expect(GovukDataSync.new("3:00-fish").in_progress?).to eq(false)
    end

    it "returns false if we are outside of the time range" do
      data_sync = GovukDataSync.new("22:30-8:30")
      at(hour: 21) { expect(data_sync.in_progress?).to eq(false) }
      at(hour: 22, min: 29) { expect(data_sync.in_progress?).to eq(false) }
      at(hour: 8, min: 31) { expect(data_sync.in_progress?).to eq(false) }
    end

    it "returns true if we are within the time range" do
      data_sync = GovukDataSync.new("22:30-8:30")
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
