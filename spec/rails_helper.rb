# frozen_string_literal: true

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'capybara/rails'
require 'capybara-screenshot/rspec'

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

if defined? ActiveRecord
  # Checks for pending migrations and applies them before tests are run.
  # If you are not using ActiveRecord, you can remove these lines.
  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::PendingMigrationError => e
    puts e.to_s.strip
    exit 1
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
  config.disable_monkey_patching!

  config.include_context 'with some data'
  config.include_context 'Capybara helpers'
end
