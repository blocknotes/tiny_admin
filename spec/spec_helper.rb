# frozen_string_literal: true

require 'pry'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.tty = true

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
