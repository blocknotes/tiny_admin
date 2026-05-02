# frozen_string_literal: true

module TinyAdmin
  class Support
    class << self
      def raw_html(value)
        TinyAdmin::RawHtml.new(value)
      end

      def call(value, options: [])
        options.inject(value) { |result, message| result&.send(message) } if value && options&.any?
      end

      def downcase(value, options: [])
        value&.downcase
      end

      def format(value, options: [])
        Kernel.format(options.first, value) if value && options&.any?
      end

      def label_for(value, options: [])
        value
      end

      def round(value, options: [])
        value&.round(options&.first&.to_i || 2)
      end

      def strftime(value, options: [])
        value&.strftime(options&.first || "%Y-%m-%d %H:%M")
      end

      def to_date(value, options: [])
        value&.to_date&.to_s
      rescue NoMethodError, ArgumentError
        value&.to_s
      end

      def multiline(array, options: [])
        return unless array.is_a?(Array)

        raw_html(array.join("<br/>"))
      end

      def upcase(value, options: [])
        value&.upcase
      end
    end
  end
end
