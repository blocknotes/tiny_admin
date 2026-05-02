# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Views::Components::Widgets do
  describe "with nil widgets" do
    it "renders nothing" do
      html = described_class.new(nil).call
      expect(html).to eq("")
    end
  end

  describe "with empty widgets" do
    it "renders nothing" do
      html = described_class.new([]).call
      expect(html).to eq("")
    end
  end

  describe "with valid widget classes" do
    let(:widget_class) do
      Class.new(Phlex::HTML) do
        def view_template
          plain "Widget content"
        end
      end
    end

    it "renders each widget in a card", :aggregate_failures do
      html = described_class.new([widget_class]).call
      expect(html).to include("Widget content")
      expect(html).to include("card-body")
    end
  end

  describe "with non-Phlex widget" do
    it "raises ArgumentError for non-Phlex classes" do
      expect { described_class.new([String]).call }
        .to raise_error(ArgumentError, /Widget String.*must be a subclass of Phlex::HTML/)
    end
  end
end
