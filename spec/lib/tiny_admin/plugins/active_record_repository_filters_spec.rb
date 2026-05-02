# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Plugins::ActiveRecordRepository do
  let(:post_repository) { described_class.new(Post) }

  before { setup_data(posts_count: 5) }

  describe "#apply_filters with range values" do
    it "applies gte filter" do
      post = Post.order(:id).first
      id_field = TinyAdmin::Field.new(name: "id", title: "ID", type: :integer)
      filters = { id_field => { value: { "gte" => post.id.to_s } } }
      results = post_repository.apply_filters(Post.all, filters)
      expect(results.minimum(:id)).to be >= post.id
    end

    it "applies lte filter" do
      post = Post.order(:id).last
      id_field = TinyAdmin::Field.new(name: "id", title: "ID", type: :integer)
      filters = { id_field => { value: { "lte" => post.id.to_s } } }
      results = post_repository.apply_filters(Post.all, filters)
      expect(results.maximum(:id)).to be <= post.id
    end

    it "applies both gte and lte (range)" do
      posts = Post.order(:id).limit(3)
      first_id = posts.first.id
      last_id = posts.last.id
      id_field = TinyAdmin::Field.new(name: "id", title: "ID", type: :integer)
      filters = { id_field => { value: { "gte" => first_id.to_s, "lte" => last_id.to_s } } }
      results = post_repository.apply_filters(Post.all, filters)
      expect(results.count).to eq(3)
    end

    it "ignores empty gte/lte values" do
      id_field = TinyAdmin::Field.new(name: "id", title: "ID", type: :integer)
      filters = { id_field => { value: { "gte" => "", "lte" => "" } } }
      results = post_repository.apply_filters(Post.all, filters)
      expect(results.count).to eq(Post.count)
    end
  end

  describe "#apply_filters with array values (multi-select)" do
    it "applies IN filter for multiple values" do
      posts = Post.order(:id).limit(2)
      ids = posts.map(&:id)
      id_field = TinyAdmin::Field.new(name: "id", title: "ID", type: :integer)
      filters = { id_field => { value: ids } }
      results = post_repository.apply_filters(Post.all, filters)
      expect(results.map(&:id)).to match_array(ids)
    end

    it "skips empty array values" do
      id_field = TinyAdmin::Field.new(name: "id", title: "ID", type: :integer)
      filters = { id_field => { value: ["", ""] } }
      results = post_repository.apply_filters(Post.all, filters)
      expect(results.count).to eq(Post.count)
    end
  end
end
