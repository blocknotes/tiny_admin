# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Views::Components::ActionsButtons do
  let(:settings) { TinyAdmin::Settings.instance }

  before { settings.load_settings }

  describe "with no actions" do
    it "renders an empty nav list", :aggregate_failures do
      component = described_class.new
      component.update_attributes(actions: {}, slug: "posts")
      html = component.call
      expect(html).to include("nav")
      expect(html).not_to include("nav-item")
    end
  end

  describe "with actions" do
    let(:action_class) do
      Class.new do
        def self.title
          "Export"
        end
      end
    end

    it "renders action buttons with links", :aggregate_failures do
      component = described_class.new
      component.update_attributes(actions: { "export" => action_class }, slug: "posts")
      html = component.call
      expect(html).to include("Export")
      expect(html).to include("export")
      expect(html).to include("nav-item")
    end

    it "includes the reference in the URL when provided" do
      component = described_class.new
      component.update_attributes(actions: { "export" => action_class }, slug: "posts", reference: "42")
      html = component.call
      expect(html).to include("42")
    end
  end

  describe "with an action class that does not respond to title" do
    it "falls back to the action key as label" do
      action_class = Class.new
      component = described_class.new
      component.update_attributes(actions: { "download" => action_class }, slug: "posts")
      html = component.call
      expect(html).to include("download")
    end
  end
end
