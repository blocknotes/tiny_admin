# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Actions::Index do
  let(:repository) { TinyAdmin::Plugins::ActiveRecordRepository.new(Post) }
  let(:request) { instance_double(Rack::Request, params: {}) }
  let(:context) do
    TinyAdmin::Context.new(
      actions: {},
      repository: repository,
      request: request,
      router: nil,
      slug: "posts"
    )
  end

  before { setup_data(posts_count: 3) }

  describe "#merge_sort" do
    let(:action) { described_class.new }
    let(:fields) { repository.fields }

    it "returns configured sort when no params provided" do
      allow(request).to receive(:params).and_return({})
      action.instance_variable_set(:@params, {})
      configured = "id DESC"
      expect(action.send(:merge_sort, configured, fields)).to eq(configured)
    end

    it "accepts valid field sort from params" do
      allow(request).to receive(:params).and_return({ "sort" => { "title" => "asc" } })
      action.instance_variable_set(:@params, { "sort" => { "title" => "asc" } })
      result = action.send(:merge_sort, nil, fields)
      expect(result).to eq(["title ASC"])
    end

    it "rejects unknown fields to prevent injection" do
      allow(request).to receive(:params).and_return({ "sort" => { "DROP TABLE posts" => "asc" } })
      action.instance_variable_set(:@params, { "sort" => { "DROP TABLE posts" => "asc" } })
      configured = "id DESC"
      expect(action.send(:merge_sort, configured, fields)).to eq(configured)
    end

    it "normalises direction to ASC or DESC" do
      allow(request).to receive(:params).and_return({ "sort" => { "title" => "invalid" } })
      action.instance_variable_set(:@params, { "sort" => { "title" => "invalid" } })
      result = action.send(:merge_sort, nil, fields)
      expect(result).to eq(["title ASC"])
    end
  end

  # show_link propagation is tested at the view level in views/actions/index_new_features_spec.rb
end
