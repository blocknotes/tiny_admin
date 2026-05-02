# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Views::Components::FiltersForm do
  let(:component) { described_class.new }

  before do
    TinyAdmin::Settings.instance.load_settings
    component.update_attributes(section_path: "/admin/posts", filters: filters)
  end

  describe "range filter" do
    let(:field) { TinyAdmin::Field.new(name: "age", type: :integer, title: "Age", options: {}) }
    let(:filters) { { field => { filter: { type: :range }, value: { "gte" => "18", "lte" => "65" } } } }

    it "renders two inputs for min and max", :aggregate_failures do
      html = component.call
      expect(html).to include('name="q[age][gte]"')
      expect(html).to include('name="q[age][lte]"')
      expect(html).to include('value="18"')
      expect(html).to include('value="65"')
    end
  end

  describe "multi-value select filter" do
    let(:field) { TinyAdmin::Field.new(name: "state", type: :string, title: "State", options: {}) }
    let(:filters) do
      {
        field => {
          filter: { type: :select, values: %w[draft published archived], multiple: true },
          value: ["published"]
        }
      }
    end

    it "renders a multiple select element", :aggregate_failures do
      html = component.call
      expect(html).to include("multiple")
      expect(html).to include("published")
      expect(html).to include("draft")
      expect(html).to include("archived")
    end
  end

  describe "association filter" do
    let(:author_class) do
      Struct.new(:id, :name) do
        def self.all = [new(1, "Alice"), new(2, "Bob")]
      end
    end

    let(:field) { TinyAdmin::Field.new(name: "author_id", type: :integer, title: "Author", options: {}) }
    let(:filters) do
      {
        field => {
          filter: { type: :association, association: author_class, value_field: :id, label_field: :name },
          value: "1"
        }
      }
    end

    it "renders a select with options from the associated model", :aggregate_failures do
      html = component.call
      expect(html).to include("Alice")
      expect(html).to include("Bob")
      expect(html).to include('value="1"')
      expect(html).to include('value="2"')
    end
  end
end
