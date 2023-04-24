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

    def prepare_page(page_class, options: nil)
      page_class.new.tap do |page|
        page.options = options
        page.head_component = settings.components[:head]&.new
        page.flash_component = settings.components[:flash]&.new
        page.navbar_component = settings.components[:navbar]&.new
        page.navbar_component&.update_attributes(
          current_slug: context&.slug,
          root_path: settings.root_path,
          root_title: settings.root[:title],
          items: options&.include?(:no_menu) ? [] : context&.navbar
        )
        yield(page) if block_given?
      end
    end

    def route_for(section, reference: nil, action: nil, query: nil)
      root_path = settings.root_path == '/' ? nil : settings.root_path
      route = [root_path, section, reference, action].compact.join("/")
      route << "?#{query}" if query
      route[0] == '/' ? route : route.prepend('/')
    end

    def to_label(string)
      return '' unless string

      string.respond_to?(:humanize) ? string.humanize : string.tr('_', ' ').capitalize
    end

    def context
      TinyAdmin::Context.instance
    end

    def settings
      TinyAdmin::Settings.instance
    end
  end
end
