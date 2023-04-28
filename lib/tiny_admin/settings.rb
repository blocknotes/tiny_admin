# frozen_string_literal: true

module TinyAdmin
  class Settings
    include Singleton
    include Utils

    DEFAULTS = {
      %i[authentication plugin] => Plugins::NoAuth,
      %i[authentication login] => Views::Pages::SimpleAuthLogin,
      %i[components flash] => Views::Components::Flash,
      %i[components head] => Views::Components::Head,
      %i[components navbar] => Views::Components::Navbar,
      %i[components pagination] => Views::Components::Pagination,
      %i[content_page] => Views::Pages::Content,
      %i[helper_class] => Support,
      %i[page_not_found] => Views::Pages::PageNotFound,
      %i[record_not_found] => Views::Pages::RecordNotFound,
      %i[repository] => Plugins::ActiveRecordRepository,
      %i[root_path] => '/admin',
      %i[root page] => Views::Pages::Root,
      %i[root title] => 'TinyAdmin'
    }.freeze

    OPTIONS = %i[
      authentication
      components
      content_page
      extra_styles
      helper_class
      page_not_found
      record_not_found
      repository
      root
      root_path
      sections
      scripts
      style_links
    ].freeze

    OPTIONS.each do |option|
      define_method(option) do
        self[option]
      end

      define_method("#{option}=") do |value|
        self[option] = value
      end
    end

    def [](*path)
      key, option = fetch_setting(path)
      option[key]
    end

    def []=(*path, value)
      key, option = fetch_setting(path)
      option[key] = value
      convert_value(key, value)
    end

    def load_settings
      # default values
      DEFAULTS.each do |(option, param), default|
        if param
          self[option] ||= {}
          self[option][param] ||= default
        else
          self[option] ||= default
        end
      end

      context.pages ||= {}
      context.resources ||= {}
      self.sections ||= []
      self.root_path = '/' if root_path == ''

      if authentication[:plugin] <= Plugins::SimpleAuth
        authentication[:logout] ||= { name: 'logout', path: "#{root_path}/auth/logout" }
      end
      context.navbar = prepare_navbar(sections, logout: authentication[:logout])
    end

    def reset!
      @options = {}
    end

    private

    def fetch_setting(path)
      @options ||= {}
      *parts, last = path.map(&:to_sym)
      [last, parts.inject(@options) { |result, part| result[part] ||= {} }]
    end

    def convert_value(key, value)
      if value.is_a?(Hash)
        value.each_key do |key2|
          path = [key, key2]
          if DEFAULTS[path].is_a?(Class) || DEFAULTS[path].is_a?(Module)
            self[key][key2] = Object.const_get(self[key][key2])
          end
        end
      elsif value.is_a?(String) && (DEFAULTS[[key]].is_a?(Class) || DEFAULTS[[key]].is_a?(Module))
        self[key] = Object.const_get(self[key])
      end
    end

    def prepare_navbar(sections, logout:)
      items = sections.each_with_object({}) do |section, list|
        unless section.is_a?(Hash)
          section_class = section.is_a?(String) ? Object.const_get(section) : section
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
      items['auth/logout'] = logout if logout
      items
    end

    def add_content_section(slug, section)
      context.pages[slug] = { class: content_page, content: section[:content] }
      { name: section[:name], path: route_for(slug), class: content_page }
    end

    def add_page_section(slug, section)
      page = section[:page]
      page_class = page.is_a?(String) ? Object.const_get(page) : page
      context.pages[slug] = { class: page_class }
      { name: section[:name], path: route_for(slug), class: page_class }
    end

    def add_resource_section(slug, section)
      repo = section[:repository] || repository
      context.resources[slug] = {
        model: section[:model].is_a?(String) ? Object.const_get(section[:model]) : section[:model],
        repository: repo.is_a?(String) ? Object.const_get(repo) : repo
      }
      resource_options = section.slice(:resource, :only, :index, :show, :collection_actions, :member_actions)
      resource_options[:only] ||= %i[index show]
      context.resources[slug].merge!(resource_options)
      hidden = section[:options] && (section[:options].include?(:hidden) || section[:options].include?('hidden'))
      { name: section[:name], path: route_for(slug) } unless hidden
    end

    def add_url_section(_slug, section)
      section.slice(:name, :options).tap { _1[:path] = section[:url] }
    end
  end
end
