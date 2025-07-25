# Coverage reporting setup
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/examples/'
    add_filter '/bin/'
    coverage_dir 'coverage'

    add_group 'Library', 'lib'

    # Minimum coverage thresholds
    minimum_coverage 80
    minimum_coverage_by_file 70
  end
end

require_relative '../lib/compress/bsc'

RSpec.configure do |config|
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

  config.default_formatter = "doc" if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  # Initialize BSC library before running tests
  config.before(:suite) do
    begin
      Compress::BSC.new
    rescue Compress::BSC::Error => e
      warn "Warning: Could not initialize BSC library: #{e.message}"
      warn "Some tests may fail. Please ensure libbsc is installed."
    rescue LoadError => e
      warn "Warning: Could not load BSC library: #{e.message}"
      warn "Please install libbsc library. See README for instructions."
    end
  end
end
