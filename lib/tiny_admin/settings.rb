# frozen_string_literal: true

module TinyAdmin
  class Settings
    include Singleton

    DEFAULTS = {
      %i[authentication plugin] => Plugins::NoAuth,
      %i[authentication login] => Views::Pages::SimpleAuthLogin,
      %i[authorization_class] => Plugins::Authorization,
      %i[components field_value] => Views::Components::FieldValue,
      %i[components flash] => Views::Components::Flash,
      %i[components head] => Views::Components::Head,
      %i[components navbar] => Views::Components::Navbar,
      %i[components pagination] => Views::Components::Pagination,
      %i[content_page] => Views::Pages::Content,
      %i[helper_class] => Support,
      %i[page_not_allowed] => Views::Pages::PageNotAllowed,
      %i[page_not_found] => Views::Pages::PageNotFound,
      %i[record_not_found] => Views::Pages::RecordNotFound,
      %i[repository] => Plugins::ActiveRecordRepository,
      %i[root_path] => "/admin",
      %i[root page] => Views::Pages::Root,
      %i[root title] => "TinyAdmin",
      %i[sections] => []
    }.freeze

    OPTIONS = %i[
      authentication
      authorization_class
      components
      content_page
      extra_styles
      helper_class
      page_not_allowed
      page_not_found
      record_not_found
      repository
      root
      root_path
      sections
      scripts
      strict_config
      style_links
    ].freeze

    # Valid section type values (as symbols).
    VALID_SECTION_TYPES = %i[content page resource url].freeze

    # Repository interface methods that must be present on a repository class.
    REPOSITORY_INTERFACE = %i[fields index_record_attrs show_record_attrs index_title show_title find collection list].freeze

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
      return if @loaded

      # default values
      DEFAULTS.each do |(option, param), default|
        if param
          self[option] ||= {}
          self[option][param] ||= default
        else
          self[option] ||= default
        end
      end

      validate_config!

      @store ||= TinyAdmin::Store.new(self)
      self.root_path = "/" if root_path == ""

      if authentication[:plugin].is_a?(Module) && authentication[:plugin] <= Plugins::SimpleAuth
        logout_path = "#{root_path}/auth/logout"
        authentication[:logout] ||= TinyAdmin::Section.new(name: "logout", slug: "logout", path: logout_path)
      end
      store.prepare_sections(sections, logout: authentication[:logout])

      @loaded = true
    end

    def reset!
      @options = {
        components: {},
        sections: []
      }
      @store = nil
      @loaded = false
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
            self[key][key2] = resolve_class(self[key][key2], setting: "#{key}.#{key2}")
          end
        end
      elsif value.is_a?(String) && (DEFAULTS[[key]].is_a?(Class) || DEFAULTS[[key]].is_a?(Module))
        self[key] = resolve_class(self[key], setting: key.to_s)
      end
    end

    def resolve_class(class_name, setting:)
      Object.const_get(class_name)
    rescue NameError => e
      raise NameError, "TinyAdmin: invalid class '#{class_name}' for setting '#{setting}' - #{e.message}"
    end

    # Validate the current configuration, raising or warning about problems.
    # When strict_config: true is set, all issues raise ArgumentError; otherwise
    # they emit a warning via Kernel.warn.
    def validate_config!
      @options ||= {}

      # Unknown top-level keys
      unknown_keys = @options.keys - OPTIONS
      unknown_keys.each do |key|
        config_problem("unknown configuration key '#{key}' – did you mean one of #{OPTIONS.join(', ')}?")
      end

      # Section type validation
      Array(sections).each do |section|
        next unless section.is_a?(Hash)

        type = section[:type]&.to_sym
        next if VALID_SECTION_TYPES.include?(type)

        config_problem(
          "section '#{section[:slug]}' has invalid type '#{section[:type]}' – must be one of #{VALID_SECTION_TYPES.join(', ')}"
        )
      end

      # Repository interface check
      repo = repository
      if repo && repo.is_a?(Module)
        missing = REPOSITORY_INTERFACE.reject { |m| repo.method_defined?(m) || repo.public_instance_methods.include?(m) }
        if missing.any?
          config_problem(
            "repository '#{repo}' is missing required methods: #{missing.join(', ')}"
          )
        end
      end
    end

    def config_problem(message)
      full_message = "TinyAdmin configuration: #{message}"
      if strict_config
        raise ArgumentError, full_message
      else
        warn full_message
      end
    end
  end
end
