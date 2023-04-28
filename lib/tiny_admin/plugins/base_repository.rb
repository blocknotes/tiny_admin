# frozen_string_literal: true

module TinyAdmin
  module Plugins
    class BaseRepository
      RecordNotFound = Class.new(StandardError)

      attr_reader :model

      def initialize(model)
        @model = model
      end

      def translate_value(value, field)
        if field[:method]
          method, *options = field[:method].split(',').map(&:strip)
          if field[:converter]
            converter = Object.const_get(field[:converter])
            converter.send(method, value, options: options || [])
          else
            TinyAdmin.settings.helper_class.send(method, value, options: options || [])
          end
        else
          value&.to_s
        end
      end
    end
  end
end
