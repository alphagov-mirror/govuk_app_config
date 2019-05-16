require 'spec_helper'
require 'rails'
require 'govuk_app_config/govuk_content_security_policy'

RSpec.describe GovukContentSecurityPolicy do
  class DummyCspRailsApp < Rails::Application; end

  describe '.configure' do
    it 'builds a policy' do
      expect(GovukContentSecurityPolicy.configure).to be_a(ActionDispatch::ContentSecurityPolicy)
    end
  end
end
