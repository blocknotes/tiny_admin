# frozen_string_literal: true

module TinyAdmin
  class Field
    attr_reader :name, :options, :title, :type

    def initialize(type:, name:, title:, options: {})
      @type = type
      @name = name
      @title = title || name
      @options = options
    end

    class << self
      def create_field(name:, title:, type: nil, options: {})
        new(type: type, name: name, title: title, options: options)
      end
    end
  end
end
