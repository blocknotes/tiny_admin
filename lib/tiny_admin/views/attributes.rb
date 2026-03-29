# frozen_string_literal: true

module TinyAdmin
  module Views
    module Attributes
      def update_attributes(attributes)
        attributes.each do |key, value|
          setter = "#{key}="
          unless respond_to?(setter)
            raise ArgumentError, "#{self.class.name} does not support attribute '#{key}'"
          end

          send(setter, value)
        end
      end
    end
  end
end
