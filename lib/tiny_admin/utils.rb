# frozen_string_literal: true

module TinyAdmin
  module Utils
    def params_to_s(params)
      list = params.each_with_object([]) do |(param, value), result|
        if value.is_a?(Hash)
          values = value.map { |key, val| "#{param}[#{key}]=#{val}" }
          result.concat(values)
        else
          result.push(["#{param}=#{value}"])
        end
      end
      list.join('&')
    end

    def prepare_page(page_class, slug: nil, attributes: nil, options: nil)
      page_class.new.tap do |page|
        page.options = options
        page.head_component = TinyAdmin.settings.components[:head]&.new
        page.flash_component = TinyAdmin.settings.components[:flash]&.new
        page.navbar_component = TinyAdmin.settings.components[:navbar]&.new
        page.navbar_component&.update_attributes(
          current_slug: slug,
          root_path: TinyAdmin.settings.root_path,
          root_title: TinyAdmin.settings.root[:title],
          items: options&.include?(:no_menu) ? [] : TinyAdmin.settings.store&.navbar
        )
        attrs = attributes || {}
        attrs[:widgets] = attrs[:widgets].map { to_class(_1) } if attrs[:widgets]
        page.update_attributes(attrs) unless attrs.empty?
        yield(page) if block_given?
      end
    end

    def route_for(section, reference: nil, action: nil, query: nil)
      root_path = TinyAdmin.settings.root_path == '/' ? nil : TinyAdmin.settings.root_path
      route = [root_path, section, reference, action].compact.join("/")
      route << "?#{query}" if query
      route[0] == '/' ? route : route.prepend('/')
    end

    def to_class(klass)
      klass.is_a?(String) ? Object.const_get(klass) : klass
    end

    def to_label(string)
      return '' unless string

      string.respond_to?(:humanize) ? string.humanize : string.tr('_', ' ').capitalize
    end
  end
end
