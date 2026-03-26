# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Settings do
  let(:settings) { described_class.instance }

  # Save and restore the internal options state around each test
  around do |example|
    saved_options = settings.instance_variable_get(:@options)&.deep_dup
    saved_store = settings.instance_variable_get(:@store)
    saved_loaded = settings.instance_variable_get(:@loaded)
    example.run
  ensure
    settings.instance_variable_set(:@options, saved_options)
    settings.instance_variable_set(:@store, saved_store)
    settings.instance_variable_set(:@loaded, saved_loaded)
  end

  describe "#reset!" do
    it "clears all options" do
      settings[:root_path] = "/custom"
      settings.reset!
      expect(settings[:root_path]).to be_nil
    end
  end

  describe "#[] and #[]=" do
    it "sets and gets a simple option" do
      settings[:root_path] = "/dashboard"
      expect(settings[:root_path]).to eq("/dashboard")
    end

    it "sets and gets a nested option" do
      settings[:root, :title] = "My Admin"
      expect(settings[:root, :title]).to eq("My Admin")
    end

    it "auto-creates intermediate hashes for nested paths", :aggregate_failures do
      settings[:authentication, :plugin] = TinyAdmin::Plugins::NoAuth
      expect(settings[:authentication]).to be_a(Hash)
      expect(settings[:authentication, :plugin]).to eq(TinyAdmin::Plugins::NoAuth)
    end
  end

  describe "#convert_value" do
    it "converts a string class name to its constant for known defaults" do
      settings[:helper_class] = "TinyAdmin::Support"
      expect(settings[:helper_class]).to eq(TinyAdmin::Support)
    end

    it "converts nested string class names to constants" do
      settings[:authentication] = { plugin: "TinyAdmin::Plugins::NoAuth" }
      expect(settings[:authentication, :plugin]).to eq(TinyAdmin::Plugins::NoAuth)
    end

    it "does not convert string values that are not class-typed defaults" do
      settings[:root_path] = "/admin"
      expect(settings[:root_path]).to eq("/admin")
    end
  end

  describe "dynamic option methods" do
    it "defines reader and writer for each option" do
      settings.root_path = "/test"
      expect(settings.root_path).to eq("/test")
    end

    it "supports all OPTIONS constants", :aggregate_failures do
      TinyAdmin::Settings::OPTIONS.each do |option|
        expect(settings).to respond_to(option)
        expect(settings).to respond_to("#{option}=")
      end
    end
  end

  describe "#load_settings" do
    before { settings.reset! }

    it "populates defaults", :aggregate_failures do
      settings.load_settings
      expect(settings.root_path).to eq("/admin")
      expect(settings.helper_class).to eq(TinyAdmin::Support)
      expect(settings.repository).to eq(TinyAdmin::Plugins::ActiveRecordRepository)
    end

    it "creates a store" do
      settings.load_settings
      expect(settings.store).to be_a(TinyAdmin::Store)
    end

    it "normalizes empty root_path to /" do
      settings[:root_path] = ""
      settings.load_settings
      expect(settings.root_path).to eq("/")
    end

    it "does not override already-set values" do
      settings[:root_path] = "/custom"
      settings.load_settings
      expect(settings.root_path).to eq("/custom")
    end
  end
end
