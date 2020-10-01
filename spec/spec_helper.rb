require "active_support/testing/time_helpers"
require "byebug"
require "climate_control"
require "rspec/its"
require "webmock/rspec"

RSpec.configure do |config|
  config.include(ActiveSupport::Testing::TimeHelpers)

  # rubocop:disable Style/GlobalVars
  config.before :all do
    $cached_raven = Raven.configuration
    Raven.configuration = $cached_raven.clone
  end

  config.after :all do
    Raven.configuration = $cached_raven
  end
  # rubocop:enable Style/GlobalVars

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus

  config.example_status_persistence_file_path = "spec/examples.txt"

  config.disable_monkey_patching!

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random

  Kernel.srand config.seed
end
