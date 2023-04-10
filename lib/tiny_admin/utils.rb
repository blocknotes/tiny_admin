# frozen_string_literal: true

module TinyAdmin
  module Utils
    def params_to_s(params)
      list = params.each_with_object([]) do |(param, value), result|
        if value.is_a?(Hash)
          result.concat(value.map { |k, v| "#{param}[#{k}]=#{v}" })
        else
          result.push(["#{param}=#{value}"])
        end
      end
      list.join('&')
    end

    def prepare_page(page_class, context: nil, options: nil)
      page_class.new.tap do |page|
        page.context = context
        page.options = options
        yield(page) if block_given?
      end
    end

    def route_for(section, reference: nil, action: nil)
      root_path = settings.root_path == '/' ? nil : settings.root_path
      route = [root_path, section, reference, action].compact.join("/")
      route[0] == '/' ? route : route.prepend('/')
    end

    def context
      TinyAdmin::Context.instance
    end

    def settings
      TinyAdmin::Settings.instance
    end
  end
end
