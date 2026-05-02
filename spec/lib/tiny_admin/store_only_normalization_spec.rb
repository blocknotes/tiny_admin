# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Store do
  let(:settings) do
    instance_double(
      TinyAdmin::Settings,
      content_page: TinyAdmin::Views::Pages::Content,
      repository: TinyAdmin::Plugins::ActiveRecordRepository
    )
  end
  let(:store) { described_class.new(settings) }

  describe "#add_resource_section normalizes only to symbols" do
    it "converts string only values to symbols" do
      sections = [{ slug: "posts", name: "Posts", type: :resource, model: Post, only: ["index", "show"] }]
      store.prepare_sections(sections, logout: nil)
      expect(store.resources["posts"][:only]).to eq(%i[index show])
    end

    it "keeps symbol only values as symbols" do
      sections = [{ slug: "posts", name: "Posts", type: :resource, model: Post, only: %i[index] }]
      store.prepare_sections(sections, logout: nil)
      expect(store.resources["posts"][:only]).to eq(%i[index])
    end

    it "defaults to [:index, :show] when only is not specified" do
      sections = [{ slug: "posts", name: "Posts", type: :resource, model: Post }]
      store.prepare_sections(sections, logout: nil)
      expect(store.resources["posts"][:only]).to eq(%i[index show])
    end
  end
end
