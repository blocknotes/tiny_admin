# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe "TinyAdmin.configure" do # rubocop:disable RSpec/DescribeClass
  let(:settings) { TinyAdmin::Settings.instance }

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
