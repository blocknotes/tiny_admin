# frozen_string_literal: true

module TinyAdmin
  class Settings
    include Singleton

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
      %i[root title] => 'TinyAdmin',
      %i[sections] => []
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

    attr_reader :store

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

      @store ||= TinyAdmin::Store.new(self)
      self.root_path = '/' if root_path == ''

      if authentication[:plugin] <= Plugins::SimpleAuth
        authentication[:logout] ||= TinyAdmin::Section.new(name: 'logout', path: "#{root_path}/auth/logout")
      end
      store.prepare_sections(sections, logout: authentication[:logout])
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
          if (DEFAULTS[path].is_a?(Class) || DEFAULTS[path].is_a?(Module)) && self[key][key2].is_a?(String)
            self[key][key2] = Object.const_get(self[key][key2])
          end
        end
      elsif value.is_a?(String) && (DEFAULTS[[key]].is_a?(Class) || DEFAULTS[[key]].is_a?(Module))
        self[key] = Object.const_get(self[key])
      end
    end
  end
end
