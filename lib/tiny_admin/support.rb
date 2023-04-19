# frozen_string_literal: true

module TinyAdmin
  class Support
    class << self
      def call(value, options: [])
        options.inject(value) { |result, message| result&.send(message) } if value && options&.any?
      end

      def downcase(value, options: [])
        value&.downcase
      end

      def format(value, options: [])
        Kernel.format(options.first, value) if value && options&.any?
      end

      def round(value, options: [])
        value&.round(options&.first&.to_i || 2)
      end

      def strftime(value, options: [])
        value&.strftime(options&.first || '%Y-%m-%d %H:%M')
      end

      def to_date(value, options: [])
        value.to_date.to_s if value
      end

      def upcase(value, options: [])
        value&.upcase
      end
    end
  end
end
