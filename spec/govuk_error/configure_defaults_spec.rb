require "spec_helper"
require "rails"
require "sentry-raven"
require "govuk_app_config/govuk_error/configure_defaults"

RSpec.describe GovukError::ConfigureDefaults do
  describe ".initialize" do
    it "delegates to the passed object if it doesn't have the method defined" do
      delegated_object = double("Raven.configuration").as_null_object
      expect(delegated_object).to receive(:some_method)
      GovukError::ConfigureDefaults.new(delegated_object).some_method
    end
  end

  describe ".silence_ready" do
    it "is not set if we are not in a Rails environment" do
      hide_const("Rails")
      delegated_object = double("Raven.configuration").as_null_object
      expect(delegated_object).not_to receive(:silence_ready=)
      GovukError::ConfigureDefaults.new(delegated_object)
    end

    context "we are in a Rails environment" do
      it "is true when not in production" do
        delegated_object = double("Raven.configuration").as_null_object
        expect(delegated_object).to receive(:silence_ready=).with(true)
        GovukError::ConfigureDefaults.new(delegated_object)
      end

      it "is false in production" do
        # rubocop:disable Naming/ConstantName
        cached_rails = Rails
        Rails = class_double("Rails", env: double("env", production?: true))
        delegated_object = double("Raven.configuration").as_null_object
        expect(delegated_object).to receive(:silence_ready=).with(false)
        GovukError::ConfigureDefaults.new(delegated_object)
        Rails = cached_rails
        # rubocop:enable Naming/ConstantName
      end
    end
  end
end
