# frozen_string_literal: true

RSpec.describe TinyAdmin::Utils do
  let(:utils_instance) { Class.new { include TinyAdmin::Utils }.new }

  describe "#params_to_s" do
    it "converts flat params to a query string" do
      expect(utils_instance.params_to_s("page" => "2", "sort" => "name")).to eq("page=2&sort=name")
    end

    it "converts nested hash params to bracket notation", :aggregate_failures do
      result = utils_instance.params_to_s("q" => { "title" => "test", "author" => "john" })
      expect(result).to include("q[title]=test")
      expect(result).to include("q[author]=john")
    end

    it "handles empty params" do
      expect(utils_instance.params_to_s({})).to eq("")
    end

    it "handles mixed flat and nested params", :aggregate_failures do
      result = utils_instance.params_to_s("p" => "1", "q" => { "name" => "test" })
      expect(result).to include("p=1")
      expect(result).to include("q[name]=test")
    end
  end

  describe "#to_class" do
    it "resolves a string to a constant" do
      expect(utils_instance.to_class("String")).to eq(String)
    end

    it "returns a class as-is" do
      expect(utils_instance.to_class(String)).to eq(String)
    end

    it "resolves namespaced strings" do
      expect(utils_instance.to_class("TinyAdmin::Support")).to eq(TinyAdmin::Support)
    end
  end

  describe "#humanize" do
    it "replaces underscores and capitalizes" do
      expect(utils_instance.humanize("some_field_name")).to eq("Some field name")
    end

    it "returns empty string for nil" do
      expect(utils_instance.humanize(nil)).to eq("")
    end

    it "handles single word" do
      expect(utils_instance.humanize("name")).to eq("Name")
    end
  end
end
