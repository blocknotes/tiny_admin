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

  describe "with a RawHtml value" do
    let(:field) { TinyAdmin::Field.new(name: "items", type: :string, title: "Items", options: { method: "multiline" }) }
    let(:record) { double("record", id: 1) } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(TinyAdmin.settings.helper_class).to receive(:multiline)
        .and_return(TinyAdmin::RawHtml.new("1<br/>2<br/>3"))
    end

    it "renders the value as raw HTML without escaping", :aggregate_failures do
      html = described_class.new(field, [1, 2, 3], record: record).call
      expect(html).to include("<span>")
      expect(html).to include("1<br/>2<br/>3")
      expect(html).not_to include("&lt;br/&gt;")
    end
  end

  describe "with a RawHtml value inside a link" do
    let(:field) { TinyAdmin::Field.new(name: "items", type: :string, title: "Items", options: { method: "multiline", link_to: "posts" }) }
    let(:record) { double("record", id: 1) } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(TinyAdmin.settings.helper_class).to receive(:multiline)
        .and_return(TinyAdmin::RawHtml.new("1<br/>2<br/>3"))
    end

    it "renders the value as raw HTML inside a link without escaping", :aggregate_failures do
      html = described_class.new(field, [1, 2, 3], record: record).call
      expect(html).to include("<a")
      expect(html).to include("<span>1<br/>2<br/>3</span>")
    end
  end

  describe "with call option (no link_to)" do
    let(:field) { TinyAdmin::Field.new(name: "author_id", type: :integer, title: "Author", options: { call: "author, name" }) }
    let(:author) { double("author", name: "John") } # rubocop:disable RSpec/VerifiedDoubles
    let(:record) { double("record", id: 1, author: author) } # rubocop:disable RSpec/VerifiedDoubles

    it "renders the call result instead of the raw value", :aggregate_failures do
      html = described_class.new(field, 42, record: record).call
      expect(html).to include("John")
      expect(html).not_to include("42")
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
