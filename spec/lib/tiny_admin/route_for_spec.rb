# frozen_string_literal: true

RSpec.describe "TinyAdmin.route_for" do # rubocop:disable RSpec/DescribeClass
  before do
    allow(TinyAdmin.settings).to receive(:root_path).and_return("/admin")
  end

  it "builds a route for a section" do
    expect(TinyAdmin.route_for("authors")).to eq("/admin/authors")
  end

  it "builds a route with a reference" do
    expect(TinyAdmin.route_for("authors", reference: "42")).to eq("/admin/authors/42")
  end

  it "builds a route with an action" do
    expect(TinyAdmin.route_for("authors", action: "edit")).to eq("/admin/authors/edit")
  end

  it "builds a route with a reference and action" do
    expect(TinyAdmin.route_for("authors", reference: "42", action: "edit")).to eq("/admin/authors/42/edit")
  end

  it "appends query string when given" do
    expect(TinyAdmin.route_for("authors", query: "page=2")).to eq("/admin/authors?page=2")
  end

  it "handles root_path of /" do
    allow(TinyAdmin.settings).to receive(:root_path).and_return("/")
    expect(TinyAdmin.route_for("authors")).to eq("/authors")
  end

  it "prepends / when missing" do
    allow(TinyAdmin.settings).to receive(:root_path).and_return("")
    expect(TinyAdmin.route_for("authors")).to eq("/authors")
  end
end
