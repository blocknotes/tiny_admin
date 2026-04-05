# frozen_string_literal: true

RSpec.describe "Standalone TinyAdmin::Settings" do
  subject(:settings) { TinyAdmin::Settings.instance }

  let(:app) { TinyAdmin::Router }

  describe "#root=" do
    it "stores and returns the root hash" do
      settings.root = { title: "Admin", content: "Some content" }
      expect(settings.root).to include(title: "Admin")
    end
  end

  describe "#sections=" do
    it "stores a list of section hashes" do
      sections = [{ slug: "a", name: "A", type: "content", content: "" }]
      settings.sections = sections
      expect(settings.sections).to eq(sections)
    end

    it "defaults to an empty collection when not set" do
      settings.reset!
      expect(settings.sections).to be_empty
    end
  end

  describe "#authentication=" do
    it "accepts a plugin hash" do
      settings.authentication = { plugin: TinyAdmin::Plugins::NoAuth }
      expect(settings.authentication[:plugin]).to eq(TinyAdmin::Plugins::NoAuth)
    end
  end

  describe "#reset" do
    it "clears previously set values" do
      settings.root = { title: "Before reset" }
      settings.reset!
      expect(settings.root).to be_nil
    end
  end
end
