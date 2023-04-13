# frozen_string_literal: true

module TinyAdmin
  module Views
    class BasicLayout < Phlex::HTML
      include Utils

      def update_attributes(attributes)
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end
    end
  end
end
