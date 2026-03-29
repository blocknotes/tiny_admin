# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class FieldValue < BasicComponent
        attr_reader :field, :value, :record

        def initialize(field, value, record:)
          @field = field
          @value = value
          @record = record
        end

        def view_template
          translated_value = field.translate_value(value)
          display_value = field.apply_call_option(record) || translated_value
          value_class = field.options[:options]&.include?("value_class") ? "value-#{value}" : nil
          if field.options[:link_to]
            a(href: TinyAdmin.route_for(field.options[:link_to], reference: translated_value)) {
              span(class: value_class) {
                render_value(display_value)
              }
            }
          else
            span(class: value_class) {
              render_value(display_value)
            }
          end
        end

        private

        def render_value(val)
          if val.is_a?(TinyAdmin::RawHtml)
            unsafe_raw(val.to_s)
          else
            val
          end
        end
      end
    end
  end
end
