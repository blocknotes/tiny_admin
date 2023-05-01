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
      @navbar = sections.each_with_object({}) do |section, list|
        unless section.is_a?(Hash)
          section_class = to_class(section)
          next unless section_class.respond_to?(:to_h)

          section = section_class.to_h
        end

        slug = section[:slug].to_s
        case section[:type]&.to_sym
        when :content
          list[slug] = add_content_section(slug, section)
        when :page
          list[slug] = add_page_section(slug, section)
        when :resource
          list[slug] = add_resource_section(slug, section)
        when :url
          list[slug] = add_url_section(slug, section)
        end
      end
      navbar['auth/logout'] = logout if logout
    end

    private

    def add_content_section(slug, section)
      pages[slug] = { class: settings.content_page, content: section[:content], widgets: section[:widgets] }
      { name: section[:name], path: route_for(slug), class: settings.content_page }
    end

    def add_page_section(slug, section)
      page_class = to_class(section[:page])
      pages[slug] = { class: page_class }
      { name: section[:name], path: route_for(slug), class: page_class }
    end

    def add_resource_section(slug, section)
      resources[slug] = {
        model: to_class(section[:model]),
        repository: to_class(section[:repository] || settings.repository)
      }
      resource_options = section.slice(:resource, :only, :index, :show, :collection_actions, :member_actions)
      resource_options[:only] ||= %i[index show]
      resources[slug].merge!(resource_options)
      hidden = section[:options] && (section[:options].include?(:hidden) || section[:options].include?('hidden'))
      { name: section[:name], path: route_for(slug) } unless hidden
    end

    def add_url_section(_slug, section)
      section.slice(:name, :options).tap { _1[:path] = section[:url] }
    end
  end
end
