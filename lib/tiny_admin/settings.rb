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
      %i[helper_class] => Support,
      %i[page_not_found] => Views::Pages::PageNotFound,
      %i[record_not_found] => Views::Pages::RecordNotFound,
      %i[repository] => Plugins::ActiveRecordRepository,
      %i[root_path] => '/admin',
      %i[root page] => Views::Pages::Root,
      %i[root title] => 'TinyAdmin'
    }.freeze

    attr_accessor :authentication,
                  :components,
                  :extra_styles,
                  :helper_class,
                  :navbar,
                  :page_not_found,
                  :record_not_found,
                  :repository,
                  :root,
                  :root_path,
                  :sections,
                  :scripts,
                  :style_links

    attr_reader :pages, :resources

    def [](key)
      send(key)
    end

    def []=(key, value)
      send("#{key}=", value)
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

      @pages ||= {}
      @resources ||= {}
      @sections ||= []
      @root_path = '/' if @root_path == ''

      if @authentication[:plugin] <= Plugins::SimpleAuth
        @authentication[:logout] ||= ['logout', "#{root_path}/auth/logout"]
      end
      @navbar = prepare_navbar(sections, logout: authentication[:logout])
    end

    private

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
        slug = section[:slug]
        case section[:type]&.to_sym
        when :url
          list[slug] = [section[:name], section[:url], section[:options]]
        when :page
          page = section[:page]
          pages[slug] = page.is_a?(String) ? Object.const_get(page) : page
          list[slug] = [section[:name], route_for(slug)]
        when :resource
          repository = section[:repository] || settings.repository
          resources[slug] = {
            model: section[:model].is_a?(String) ? Object.const_get(section[:model]) : section[:model],
            repository: repository.is_a?(String) ? Object.const_get(repository) : repository
          }
          resources[slug].merge! section.slice(:resource, :only, :index, :show, :collection_actions, :member_actions)
          hidden = section[:options] && (section[:options].include?(:hidden) || section[:options].include?('hidden'))
          list[slug] = [section[:name], route_for(slug)] unless hidden
        end
      end
      items['auth/logout'] = logout if logout
      items
    end
  end
end
