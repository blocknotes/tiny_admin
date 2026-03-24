# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Views::Components::FieldValue do
  let(:settings) { TinyAdmin::Settings.instance }

  before { settings.load_settings }

  describe "with a basic field" do
    let(:field) { TinyAdmin::Field.new(name: "title", type: :string, title: "Title", options: {}) }
    let(:record) { double("record", id: 1) } # rubocop:disable RSpec/VerifiedDoubles

    it "renders the translated value in a span", :aggregate_failures do
      html = described_class.new(field, "Hello", record: record).call
      expect(html).to include("Hello")
      expect(html).to include("<span")
    end
  end

  describe "with link_to option" do
    let(:field) { TinyAdmin::Field.new(name: "author_id", type: :integer, title: "Author", options: { link_to: "authors" }) }
    let(:record) { double("record", id: 1) } # rubocop:disable RSpec/VerifiedDoubles

    it "wraps the value in a link", :aggregate_failures do
      html = described_class.new(field, "42", record: record).call
      expect(html).to include("<a")
      expect(html).to include("authors")
      expect(html).to include("42")
    end
  end

  describe "with value_class option" do
    let(:field) { TinyAdmin::Field.new(name: "status", type: :string, title: "Status", options: { options: ["value_class"] }) }
    let(:record) { double("record", id: 1) } # rubocop:disable RSpec/VerifiedDoubles

    it "adds value-based CSS class to the span" do
      html = described_class.new(field, "active", record: record).call
      expect(html).to include("value-active")
    end
  end
end
