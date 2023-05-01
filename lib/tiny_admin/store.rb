# frozen_string_literal: true

module TinyAdmin
  class Store
    include Utils

    attr_reader :navbar, :pages, :resources, :settings

    def initialize(settings)
      @pages = {}
      @resources = {}
      @settings = settings
    end

    def prepare_sections(sections, logout:)
      @navbar = sections.each_with_object([]) do |section, list|
        unless section.is_a?(Hash)
          section_class = to_class(section)
          next unless section_class.respond_to?(:to_h)

          section = section_class.to_h
        end

        slug = section[:slug].to_s
        case section[:type]&.to_sym
        when :content
          list << add_content_section(slug, section)
        when :page
          list << add_page_section(slug, section)
        when :resource
          list << add_resource_section(slug, section)
        when :url
          list << add_url_section(slug, section)
        end
      end
      navbar << logout if logout
    end

    private

    def add_content_section(slug, section)
      pages[slug] = { class: settings.content_page, content: section[:content], widgets: section[:widgets] }
      TinyAdmin::Section.new(name: section[:name], slug: slug)
    end

    def add_page_section(slug, section)
      pages[slug] = { class: to_class(section[:page]) }
      TinyAdmin::Section.new(name: section[:name], slug: slug)
    end

    def add_resource_section(slug, section)
      resource = section.slice(:resource, :only, :index, :show, :collection_actions, :member_actions)
      resource[:only] ||= %i[index show]
      resources[slug] = resource.merge(
        model: to_class(section[:model]),
        repository: to_class(section[:repository] || settings.repository)
      )

      hidden = section[:options] && (section[:options].include?(:hidden) || section[:options].include?('hidden'))
      TinyAdmin::Section.new(name: section[:name], slug: slug) unless hidden
    end

    def add_url_section(slug, section)
      TinyAdmin::Section.new(name: section[:name], options: section[:options], path: section[:url], slug: slug)
    end
  end
end
