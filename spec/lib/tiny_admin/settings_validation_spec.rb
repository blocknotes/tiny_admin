# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Settings do
  let(:settings) { described_class.instance }

  describe "#load_settings validation" do
    context "with an unknown top-level key" do
      before { settings[:unknown_key] = "value" }

      it "emits a warning in default mode" do
        expect { settings.load_settings }
          .to output(/unknown configuration key 'unknown_key'/).to_stderr
      end

      it "raises in strict mode" do
        settings[:strict_config] = true
        expect { settings.load_settings }
          .to raise_error(ArgumentError, /unknown configuration key 'unknown_key'/)
      end
    end

    context "with an invalid section type" do
      before do
        settings[:sections] = [{ slug: "test", name: "Test", type: :invalid_type }]
        settings[:strict_config] = true
      end

      it "raises for invalid section type" do
        expect { settings.load_settings }
          .to raise_error(ArgumentError, /invalid type 'invalid_type'/)
      end
    end

    context "with a repository missing required methods" do
      let(:broken_repo) do
        Class.new do
          # Missing most required methods
          def initialize(_model); end
        end
      end

      before do
        settings[:repository] = broken_repo
        settings[:strict_config] = true
      end

      it "raises for a repository missing required methods" do
        expect { settings.load_settings }
          .to raise_error(ArgumentError, /missing required methods/)
      end
    end

    context "with valid configuration" do
      it "does not warn or raise" do
        expect { settings.load_settings }.not_to raise_error
      end
    end
  end
end
