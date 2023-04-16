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
        field_title = title || name.respond_to?(:humanize) ? name.humanize : name.tr('_', ' ').capitalize
        new(name: name, title: field_title, type: type || :string, options: options)
      end
    end
  end
end
