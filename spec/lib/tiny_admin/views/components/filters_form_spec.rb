# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Views::Components::FiltersForm do
  let(:component) { described_class.new }

  before do
    TinyAdmin::Settings.instance.load_settings
    component.update_attributes(section_path: "/admin/posts", filters: filters)
  end

  describe "with a boolean filter" do
    let(:field) { TinyAdmin::Field.new(name: "published", type: :boolean, title: "Published", options: {}) }
    let(:filters) { { field => { filter: { type: :boolean }, value: "1" } } }

    it "renders a select with true/false options", :aggregate_failures do
      html = component.call
      expect(html).to include("form-select")
      expect(html).to include("true")
      expect(html).to include("false")
    end
  end

  describe "with a date filter" do
    let(:field) { TinyAdmin::Field.new(name: "created_at", type: :date, title: "Created At", options: {}) }
    let(:filters) { { field => { filter: { type: :date }, value: "2024-01-01" } } }

    it "renders a date input", :aggregate_failures do
      html = component.call
      expect(html).to include('type="date"')
      expect(html).to include("2024-01-01")
    end
  end

  describe "with a datetime filter" do
    let(:field) { TinyAdmin::Field.new(name: "updated_at", type: :datetime, title: "Updated At", options: {}) }
    let(:filters) { { field => { filter: { type: :datetime }, value: "2024-01-01T12:00" } } }

    it "renders a datetime-local input" do
      html = component.call
      expect(html).to include('type="datetime-local"')
    end
  end

  describe "with an integer filter" do
    let(:field) { TinyAdmin::Field.new(name: "age", type: :integer, title: "Age", options: {}) }
    let(:filters) { { field => { filter: { type: :integer }, value: "25" } } }

    it "renders a number input" do
      html = component.call
      expect(html).to include('type="number"')
    end
  end

  describe "with a select filter" do
    let(:field) { TinyAdmin::Field.new(name: "state", type: :select, title: "State", options: {}) }
    let(:filters) { { field => { filter: { type: :select, values: %w[available unavailable] }, value: "available" } } }

    it "renders a select with the provided values", :aggregate_failures do
      html = component.call
      expect(html).to include("form-select")
      expect(html).to include("available")
      expect(html).to include("unavailable")
    end
  end

  describe "with a text filter (default)" do
    let(:field) { TinyAdmin::Field.new(name: "title", type: :string, title: "Title", options: {}) }
    let(:filters) { { field => { filter: {}, value: "hello" } } }

    it "renders a text input", :aggregate_failures do
      html = component.call
      expect(html).to include('type="text"')
      expect(html).to include("hello")
    end
  end

  describe "action buttons" do
    let(:field) { TinyAdmin::Field.new(name: "title", type: :string, title: "Title", options: {}) }
    let(:filters) { { field => { filter: {}, value: "" } } }

    it "renders Clear and Filter buttons", :aggregate_failures do
      html = component.call
      expect(html).to include("Clear")
      expect(html).to include("Filter")
    end
  end
end
