# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe "Load Settings idempotency" do # rubocop:disable RSpec/DescribeClass
  let(:settings) { TinyAdmin::Settings.instance }

  around do |example|
    saved = settings.instance_variable_get(:@options)&.deep_dup
    saved_store = settings.instance_variable_get(:@store)
    saved_loaded = settings.instance_variable_get(:@loaded)
    example.run
  ensure
    settings.instance_variable_set(:@options, saved)
    settings.instance_variable_set(:@store, saved_store)
    settings.instance_variable_set(:@loaded, saved_loaded)
  end

  it "does not re-run on subsequent calls" do
    settings.reset!
    settings.load_settings
    store = settings.store
    settings.load_settings
    expect(settings.store).to equal(store)
  end

  it "runs again after reset!" do
    settings.reset!
    settings.load_settings
    store = settings.store

    settings.reset!
    settings.load_settings
    expect(settings.store).not_to equal(store)
  end
end
