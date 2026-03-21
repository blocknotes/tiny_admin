# frozen_string_literal: true

require "dummy_rails_app"
require "rails_helper"

RSpec.describe TinyAdmin::Plugins::ActiveRecordRepository do
  let(:repository) { described_class.new(Author) }

  before { setup_data(posts_count: 12) }

  describe "#index_title" do
    it "returns the pluralized model name" do
      expect(repository.index_title).to eq("Authors")
    end
  end

  describe "#show_title" do
    it "returns the model name with the record id" do
      author = Author.first
      expect(repository.show_title(author)).to eq("Author ##{author.id}")
    end
  end

  describe "#fields" do
    it "returns all model columns as Field objects when no options given", :aggregate_failures do
      fields = repository.fields
      expect(fields).to be_a(Hash)
      expect(fields.keys).to include("id", "name", "age", "email")
      expect(fields["name"]).to be_a(TinyAdmin::Field)
      expect(fields["name"].type).to eq(:string)
    end

    it "returns only specified fields when options given" do
      options = {"name" => {}, "email" => {}}
      fields = repository.fields(options: options)
      expect(fields.keys).to eq(["name", "email"])
    end

    it "maps column types correctly", :aggregate_failures do
      fields = repository.fields
      expect(fields["id"].type).to eq(:integer)
      expect(fields["name"].type).to eq(:string)
      expect(fields["age"].type).to eq(:integer)
    end
  end

  describe "#find" do
    it "returns the record for a valid id" do
      author = Author.first
      expect(repository.find(author.id)).to eq(author)
    end

    it "raises RecordNotFound for an invalid id" do
      expect { repository.find(999_999) }
        .to raise_error(TinyAdmin::Plugins::BaseRepository::RecordNotFound)
    end
  end

  describe "#collection" do
    it "returns all records" do
      expect(repository.collection.count).to eq(Author.count)
    end
  end

  describe "#index_record_attrs" do
    let(:author) { Author.first }

    it "returns all attributes as strings when no fields given", :aggregate_failures do
      attrs = repository.index_record_attrs(author)
      expect(attrs["name"]).to eq(author.name)
      expect(attrs["id"]).to eq(author.id.to_s)
    end

    it "returns only specified fields when fields given", :aggregate_failures do
      attrs = repository.index_record_attrs(author, fields: {"name" => nil, "email" => nil})
      expect(attrs.keys).to eq(["name", "email"])
      expect(attrs["name"]).to eq(author.name)
    end
  end

  describe "#list" do
    it "returns records and total count", :aggregate_failures do
      records, count = repository.list(page: 1, limit: 2)
      expect(records.size).to eq(2)
      expect(count).to eq(3)
    end

    it "paginates correctly", :aggregate_failures do
      records_page1, = repository.list(page: 1, limit: 2)
      records_page2, = repository.list(page: 2, limit: 2)
      expect(records_page1).not_to eq(records_page2)
      expect(records_page2.size).to eq(1)
    end

    it "sorts when sort option given" do
      records, = repository.list(page: 1, limit: 10, sort: {name: :desc})
      names = records.map(&:name)
      expect(names).to eq(names.sort.reverse)
    end
  end

  describe "#apply_filters" do
    let(:post_repository) { described_class.new(Post) }

    it "filters string fields with LIKE" do
      title_field = TinyAdmin::Field.new(name: "title", title: "Title", type: :string)
      filters = {title_field => {value: "post 1"}}
      results = post_repository.apply_filters(Post.all, filters)
      results.each do |post|
        expect(post.title.downcase).to include("post 1")
      end
    end

    it "filters non-string fields with equality" do
      author = Author.first
      author_field = TinyAdmin::Field.new(name: "author_id", title: "Author", type: :integer)
      filters = {author_field => {value: author.id}}
      results = post_repository.apply_filters(Post.all, filters)
      results.each do |post|
        expect(post.author_id).to eq(author.id)
      end
    end

    it "skips filters with nil or empty values" do
      title_field = TinyAdmin::Field.new(name: "title", title: "Title", type: :string)
      filters = {title_field => {value: nil}}
      results = post_repository.apply_filters(Post.all, filters)
      expect(results.count).to eq(Post.count)
    end

    it "sanitizes SQL LIKE input" do
      title_field = TinyAdmin::Field.new(name: "title", title: "Title", type: :string)
      filters = {title_field => {value: "100%"}}
      # Should not raise or cause SQL injection
      expect { post_repository.apply_filters(Post.all, filters).to_a }.not_to raise_error
    end
  end
end
