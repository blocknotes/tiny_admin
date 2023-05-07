# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class FieldValue < BasicComponent
        def initialize(field, value, record:)
          @field = field
          @value = value
          @record = record
        end

        def template
          val = @field.translate_value(@value)
          if @field.options && @field.options[:link_to]
            a(href: TinyAdmin.route_for(@field.options[:link_to], reference: val)) {
              @field.apply_call_option(@record) || val
            }
          else
            span {
              val
            }
          end
        end
      end
    end
  end
end
