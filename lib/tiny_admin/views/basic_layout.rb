# frozen_string_literal: true

module TinyAdmin
  module Views
    class BasicLayout < Phlex::HTML
      include Utils

      attr_accessor :content, :params, :widgets

      def label_for(value, options: [])
        TinyAdmin.settings.helper_class.label_for(value, options: options)
      end

      def update_attributes(attributes)
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end
    end
  end
end
