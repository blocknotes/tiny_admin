# frozen_string_literal: true

RSpec.describe TinyAdmin::Actions::BasicAction do
  let(:action) { described_class.new }

  describe "#attribute_options" do
    it "returns nil for nil input" do
      expect(action.attribute_options(nil)).to be_nil
    end

    it "handles simple string field names" do
      result = action.attribute_options(["id", "name"])
      expect(result).to eq(
        "id" => {field: "id"},
        "name" => {field: "name"}
      )
    end

    it "handles single-entry hash with method shorthand" do
      result = action.attribute_options([{title: "downcase, capitalize"}])
      expect(result).to eq(
        "title" => {field: "title", method: "downcase, capitalize"}
      )
    end

    it "handles multi-entry hash with explicit field key" do
      result = action.attribute_options([{field: "author_id", link_to: "authors"}])
      expect(result).to eq(
        "author_id" => {field: "author_id", link_to: "authors"}
      )
    end

    it "handles mixed input types" do
      result = action.attribute_options([
        "id",
        {title: "upcase"},
        {field: "created_at", method: "strftime, %Y-%m-%d"}
      ])
      expect(result).to eq(
        "id" => {field: "id"},
        "title" => {field: "title", method: "upcase"},
        "created_at" => {field: "created_at", method: "strftime, %Y-%m-%d"}
      )
    end
  end
end
