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

  describe "#initialize" do
    it "starts with empty pages and resources", :aggregate_failures do
      expect(store.pages).to eq({})
      expect(store.resources).to eq({})
    end
  end

  describe "#prepare_sections" do
    context "with a content section" do
      let(:sections) do
        [{slug: "about", name: "About", type: :content, content: "<h1>About</h1>"}]
      end

      it "adds to pages and navbar", :aggregate_failures do
        store.prepare_sections(sections, logout: nil)
        expect(store.pages).to have_key("about")
        expect(store.pages["about"][:content]).to eq("<h1>About</h1>")
        expect(store.pages["about"][:class]).to eq(TinyAdmin::Views::Pages::Content)
        expect(store.navbar.size).to eq(1)
        expect(store.navbar.first.name).to eq("About")
      end
    end

    context "with a page section" do
      let(:page_class) do
        Class.new(TinyAdmin::Views::Pages::Root)
      end

      let(:sections) do
        [{slug: "dashboard", name: "Dashboard", type: :page, page: page_class}]
      end

      it "adds to pages and navbar", :aggregate_failures do
        store.prepare_sections(sections, logout: nil)
        expect(store.pages).to have_key("dashboard")
        expect(store.pages["dashboard"][:class]).to eq(page_class)
        expect(store.navbar.size).to eq(1)
        expect(store.navbar.first.name).to eq("Dashboard")
      end
    end

    context "with a resource section" do
      let(:sections) do
        [{slug: "authors", name: "Authors", type: :resource, model: Author}]
      end

      it "adds to resources and navbar", :aggregate_failures do
        store.prepare_sections(sections, logout: nil)
        expect(store.resources).to have_key("authors")
        expect(store.resources["authors"][:model]).to eq(Author)
        expect(store.resources["authors"][:only]).to eq(%i[index show])
        expect(store.navbar.size).to eq(1)
        expect(store.navbar.first.name).to eq("Authors")
      end
    end

    context "with a hidden resource section" do
      let(:sections) do
        [{slug: "secret", name: "Secret", type: :resource, model: Author, options: [:hidden]}]
      end

      it "adds to resources but not to visible navbar items", :aggregate_failures do
        store.prepare_sections(sections, logout: nil)
        expect(store.resources).to have_key("secret")
        # Hidden resources return nil from add_resource_section, which gets collected in navbar
        expect(store.navbar.compact).to be_empty
      end
    end

    context "with a url section" do
      let(:sections) do
        [{slug: "google", name: "Google", type: :url, url: "https://google.com", options: {target: "_blank"}}]
      end

      it "adds to navbar with the url as path", :aggregate_failures do
        store.prepare_sections(sections, logout: nil)
        expect(store.navbar.size).to eq(1)
        expect(store.navbar.first.path).to eq("https://google.com")
        expect(store.navbar.first.options).to eq({target: "_blank"})
      end

      it "does not add to pages or resources", :aggregate_failures do
        store.prepare_sections(sections, logout: nil)
        expect(store.pages).to be_empty
        expect(store.resources).to be_empty
      end
    end

    context "with a section object (module)" do
      let(:section_module) do
        mod = Class.new do
          def self.to_h
            {slug: "dynamic", name: "Dynamic", type: :content, content: "<p>Hi</p>"}
          end
        end
        mod
      end

      let(:sections) { [section_module] }

      it "calls to_h on the section class", :aggregate_failures do
        store.prepare_sections(sections, logout: nil)
        expect(store.pages).to have_key("dynamic")
        expect(store.navbar.size).to eq(1)
      end
    end

    context "with a section object that does not respond to to_h" do
      let(:sections) { [Class.new] }

      it "skips the section", :aggregate_failures do
        store.prepare_sections(sections, logout: nil)
        expect(store.pages).to be_empty
        expect(store.resources).to be_empty
        expect(store.navbar).to be_empty
      end
    end

    context "with a logout section" do
      let(:logout_section) { TinyAdmin::Section.new(name: "logout", slug: "logout", path: "/admin/auth/logout") }

      it "appends logout to navbar" do
        store.prepare_sections([], logout: logout_section)
        expect(store.navbar.last.name).to eq("logout")
      end
    end

    context "with multiple section types" do
      let(:sections) do
        [
          {slug: "about", name: "About", type: :content, content: "<p>Test</p>"},
          {slug: "users", name: "Users", type: :resource, model: Author},
          {slug: "ext", name: "External", type: :url, url: "https://example.com"}
        ]
      end

      it "processes all sections correctly", :aggregate_failures do
        store.prepare_sections(sections, logout: nil)
        expect(store.pages.size).to eq(1)
        expect(store.resources.size).to eq(1)
        expect(store.navbar.size).to eq(3)
      end
    end
  end
end
