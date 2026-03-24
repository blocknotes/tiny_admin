# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe "TinyAdmin.configure" do # rubocop:disable RSpec/DescribeClass
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

  it "yields settings to the block" do
    yielded = nil
    TinyAdmin.configure { |s| yielded = s }
    expect(yielded).to eq(settings)
  end

  it "allows setting options via the block" do
    TinyAdmin.configure { |s| s.root_path = "/custom" }
    expect(settings.root_path).to eq("/custom")
  end

  it "returns settings when no block is given" do
    result = TinyAdmin.configure
    expect(result).to eq(settings)
  end
end
