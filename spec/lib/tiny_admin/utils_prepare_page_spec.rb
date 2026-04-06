# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Utils, "#prepare_page" do
  let(:utils_instance) { Class.new { include TinyAdmin::Utils }.new }
  let(:settings) { TinyAdmin::Settings.instance }

  before do
    settings.load_settings
  end

  it "returns an instance of the given page class" do
    page = utils_instance.prepare_page(TinyAdmin::Views::Pages::Root)
    expect(page).to be_a(TinyAdmin::Views::Pages::Root)
  end

  it "assigns head, flash, and navbar components", :aggregate_failures do
    page = utils_instance.prepare_page(TinyAdmin::Views::Pages::Root)
    expect(page.head_component).to be_a(TinyAdmin::Views::Components::Head)
    expect(page.flash_component).to be_a(TinyAdmin::Views::Components::Flash)
    expect(page.navbar_component).to be_a(TinyAdmin::Views::Components::Navbar)
  end

  it "sets the page title from attributes" do
    page = utils_instance.prepare_page(TinyAdmin::Views::Pages::Root, attributes: { title: "My Title" })
    expect(page.title).to eq("My Title")
  end

  it "sets params on the page" do
    page = utils_instance.prepare_page(TinyAdmin::Views::Pages::Root, params: { "page" => "2" })
    expect(page.params).to eq({ "page" => "2" })
  end

  it "passes no_menu option to hide navbar items" do
    page = utils_instance.prepare_page(TinyAdmin::Views::Pages::Root, options: [:no_menu])
    expect(page.navbar_component.items).to eq([])
  end

  it "yields the page to the block when given" do
    yielded = nil
    utils_instance.prepare_page(TinyAdmin::Views::Pages::Root) { |p| yielded = p }
    expect(yielded).to be_a(TinyAdmin::Views::Pages::Root)
  end

  it "resolves widget class names from strings" do
    widget_class = Class.new(Phlex::HTML) do
      def view_template
        plain "test"
      end
    end
    stub_const("TestWidget", widget_class)
    page = utils_instance.prepare_page(TinyAdmin::Views::Pages::Root, attributes: { widgets: ["TestWidget"] })
    expect(page.widgets).to eq([TestWidget])
  end
end
