# frozen_string_literal: true

module TinyAdmin
  module Views
    class BasicLayout < Phlex::HTML
      include Attributes
      include Utils

      attr_accessor :content, :params, :widgets

      def label_for(value, options: [])
        TinyAdmin.settings.helper_class.label_for(value, options: options)
      end
    end
  end
end
