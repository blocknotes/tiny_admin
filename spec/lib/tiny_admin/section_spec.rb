# frozen_string_literal: true

RSpec.describe TinyAdmin::Section do
  describe "#initialize" do
    it "builds a path from the slug when no path given", :aggregate_failures do
      section = described_class.new(name: "Authors", slug: "authors")
      expect(section.path).to eq(TinyAdmin.route_for("authors"))
      expect(section.name).to eq("Authors")
      expect(section.slug).to eq("authors")
    end

    it "uses the given path when provided" do
      section = described_class.new(name: "Google", slug: "google", path: "https://google.com")
      expect(section.path).to eq("https://google.com")
    end

    it "defaults options to empty hash" do
      section = described_class.new(name: "Test", slug: "test")
      expect(section.options).to eq({})
    end

    it "stores provided options" do
      section = described_class.new(name: "Link", slug: "link", options: { target: "_blank" })
      expect(section.options).to eq({ target: "_blank" })
    end
  end
end
