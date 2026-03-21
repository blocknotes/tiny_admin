# frozen_string_literal: true

RSpec.describe TinyAdmin::Plugins::Authorization do
  describe ".allowed?" do
    it "returns true for any user, action, and param", :aggregate_failures do
      expect(described_class.allowed?("admin", :root)).to be true
      expect(described_class.allowed?(nil, :page, "some_slug")).to be true
      expect(described_class.allowed?("user", :resource_index, "posts")).to be true
    end
  end
end
