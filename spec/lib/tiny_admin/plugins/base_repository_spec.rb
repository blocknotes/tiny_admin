# frozen_string_literal: true

RSpec.describe TinyAdmin::Plugins::BaseRepository do
  describe "#initialize" do
    it "stores the model" do
      repo = described_class.new(String)
      expect(repo.model).to eq(String)
    end
  end

  describe "RecordNotFound" do
    it "is a StandardError" do
      expect(described_class::RecordNotFound.new).to be_a(StandardError)
    end

    it "can be raised with a message" do
      expect { raise described_class::RecordNotFound, "not found" }
        .to raise_error(described_class::RecordNotFound, "not found")
    end
  end
end
