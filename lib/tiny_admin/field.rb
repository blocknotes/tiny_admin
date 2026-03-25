# frozen_string_literal: true

module TinyAdmin
  class Field
    attr_reader :name, :options, :title, :type

    def initialize(name:, title:, type:, options: {})
      @type = type
      @name = name
      @title = title
      @options = options
    end

    def apply_call_option(target)
      messages = (options[:call] || "").split(",").map(&:strip)
      messages.inject(target) { |result, msg| result&.send(msg) } if messages.any?
    end

    def translate_value(value)
      if options && options[:method]
        method, *args = options[:method].split(",").map(&:strip)
        if options[:converter]
          Object.const_get(options[:converter]).send(method, value, options: args || [])
        else
          TinyAdmin.settings.helper_class.send(method, value, options: args || [])
        end
      else
        value&.to_s
      end
    end

    class << self
      include Utils

      def create_field(name:, title: nil, type: nil, options: {})
        field_name = name.to_s
        new(name: field_name, title: title || humanize(field_name), type: type || :string, options: options || {})
      end
    end
  end
end
