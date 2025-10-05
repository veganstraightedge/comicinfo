require 'comicinfo'

# Helper methods for working with fixture files
module FixtureHelpers
  # Load fixture file content from either spec/fixtures or spec/comic_info/fixtures
  def fixture_file filename
    # Try spec/fixtures first (for top-level specs)
    main_fixtures_path = File.join __dir__, 'fixtures', filename
    return File.read(main_fixtures_path) if File.exist? main_fixtures_path

    raise "Fixture file not found: #{filename}"
  end

  # Get full path to fixture file
  def fixture_path filename
    # Try spec/fixtures first (for top-level specs)
    main_fixtures_path = File.join __dir__, 'fixtures', filename
    return main_fixtures_path if File.exist? main_fixtures_path

    raise "Fixture file not found: #{filename}"
  end

  # Load a ComicInfo instance from a fixture file
  def load_fixture filename
    ComicInfo.load fixture_file filename
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Include fixture helpers in all specs
  config.include FixtureHelpers
end
