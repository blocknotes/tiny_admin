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
      messages = (options[:call] || '').split(',').map(&:strip)
      messages.inject(target) { |result, msg| result&.send(msg) } if messages.any?
    end

    class << self
      def create_field(name:, title: nil, type: nil, options: {})
        field_name = name.to_s
        field_title = field_name.respond_to?(:humanize) ? field_name.humanize : field_name.tr('_', ' ').capitalize
        new(name: field_name, title: title || field_title, type: type || :string, options: options || {})
      end
    end
  end
end
