# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Views::Actions::Index do
  let(:view) { described_class.new }
  let(:field) { TinyAdmin::Field.create_field(name: "title") }
  let(:fields) { { "title" => field } }

  before { TinyAdmin::Settings.instance.load_settings }

  describe "#render_sortable_header" do
    before do
      view.update_attributes(
        actions: {},
        fields: fields,
        filters: {},
        prepare_record: ->(r) { {} },
        records: [],
        slug: "posts",
        sort_params: nil
      )
    end

    it "renders a link with the field name" do
      html = view.call
      expect(html).to include("sort-link")
      expect(html).to include("Title")
    end

    it "shows ASC indicator when currently sorted asc" do
      view.sort_params = { "title" => "asc" }
      html = view.call
      expect(html).to include("▲")
    end

    it "shows DESC indicator when currently sorted desc" do
      view.sort_params = { "title" => "desc" }
      html = view.call
      expect(html).to include("▼")
    end

    it "omits sort indicator when field is not sorted" do
      view.sort_params = {}
      html = view.call
      expect(html).not_to include("▲")
      expect(html).not_to include("▼")
    end
  end

  describe "show_link" do
    let(:fake_record) { double("record", id: 1) }

    before do
      view.update_attributes(
        actions: {},
        fields: fields,
        filters: {},
        prepare_record: ->(r) { { "title" => "Test" } },
        records: [fake_record],
        slug: "posts",
        sort_params: nil
      )
    end

    it "renders a Show link by default (show_link nil)" do
      html = view.call
      expect(html).to include("Show")
    end

    it "renders a Show link when show_link is true" do
      view.show_link = true
      html = view.call
      expect(html).to include("Show")
    end

    it "does not render Show link when show_link is false" do
      view.show_link = false
      html = view.call
      expect(html).not_to include("Show")
    end
  end
end
