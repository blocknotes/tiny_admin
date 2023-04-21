# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class BasicComponent < Phlex::HTML
        def update_attributes(attributes)
          attributes.each do |key, value|
            send("#{key}=", value)
          end
        end
      end
    end
  end
end
