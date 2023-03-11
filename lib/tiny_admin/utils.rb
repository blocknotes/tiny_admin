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

    def prepare_page(page_class, title: nil, context: nil, query_string: '', options: [])
      page_class.new.tap do |page|
        page.setup_page(title: title, query_string: query_string, settings: settings)
        page.setup_options(
          context: context,
          compact_layout: options.include?(:compact_layout),
          no_menu: options.include?(:no_menu)
        )
        yield(page) if block_given?
      end
    end

    def route_for(section, reference: nil, action: nil)
      [settings.root_path, section, reference, action].compact.join("/")
    end

    def context
      TinyAdmin::Context.instance
    end

    def settings
      TinyAdmin::Settings.instance
    end
  end
end
