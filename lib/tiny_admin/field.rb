# frozen_string_literal: true

module TinyAdmin
  class Field
    attr_reader :name, :options, :title, :type

    def initialize(name:, title:, type:, options: {})
      @type = type
      @name = name
      @title = title || name
      @options = options
    end

    class << self
      def create_field(name:, title: nil, type: nil, options: {})
        field_name = name.to_s
        new(
          name: field_name,
          title: title || field_name.respond_to?(:humanize) ? field_name.humanize : field_name.tr('_', ' ').capitalize,
          type: type || :string,
          options: options
        )
      end
    end
  end
end
