# frozen_string_literal: true

RSpec.describe TinyAdmin::Plugins::BaseRepository do
  let(:repo) { described_class.new(nil) }

  describe "#page_offset" do
    it "returns 0 for page 1 with limit 10" do
      expect(repo.send(:page_offset, 1, 10)).to eq(0)
    end

    it "returns correct offset for subsequent pages" do
      expect(repo.send(:page_offset, 2, 10)).to eq(10)
      expect(repo.send(:page_offset, 3, 10)).to eq(20)
    end

    it "returns 0 for non-positive page" do
      expect(repo.send(:page_offset, 0, 10)).to eq(0)
    end
  end
end
