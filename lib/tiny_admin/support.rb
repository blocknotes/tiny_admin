# frozen_string_literal: true

module TinyAdmin
  class Support
    class << self
      def downcase(value, options: [])
        value&.downcase
      end

      def format(value, options: [])
        value && options&.any? ? Kernel.format(options.first, value) : value
      end

      def round(value, options: [])
        value&.round(options&.first&.to_i || 2)
      end

      def strftime(value, options: [])
        value ? value.strftime(options&.first || '%Y-%m-%d %H:%M') : ''
      end

      def to_date(value, options: [])
        value ? value.to_date.to_s : value
      end

      def upcase(value, options: [])
        value&.upcase
      end
    end
  end
end
