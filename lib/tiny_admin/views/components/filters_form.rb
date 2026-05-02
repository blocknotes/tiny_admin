# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class FiltersForm < BasicComponent
        attr_accessor :filters, :section_path

        def view_template
          form(class: "form_filters", method: "get") {
            filters.each do |field, filter|
              name = field.name
              filter_data = filter[:filter]
              div(class: "mb-3") {
                label(for: "filter-#{name}", class: "form-label") { field.title }
                filter_type = filter_data[:type]&.to_sym || field.type
                case filter_type
                when :boolean
                  render_boolean_filter(name, filter)
                when :date
                  input(type: "date", class: "form-control", id: "filter-#{name}", name: "q[#{name}]", value: filter[:value])
                when :datetime
                  input(type: "datetime-local", class: "form-control", id: "filter-#{name}", name: "q[#{name}]", value: filter[:value])
                when :integer
                  input(type: "number", class: "form-control", id: "filter-#{name}", name: "q[#{name}]", value: filter[:value])
                when :range
                  render_range_filter(name, filter)
                when :select
                  render_select_filter(name, filter, filter_data)
                when :association
                  render_association_filter(name, filter, filter_data)
                else
                  input(type: "text", class: "form-control", id: "filter-#{name}", name: "q[#{name}]", value: filter[:value])
                end
              }
            end

            div(class: "mt-3") {
              a(href: section_path, class: "button_clear btn btn-secondary text-white") {
                TinyAdmin.settings.helper_class.label_for("Clear", options: ["components.filters_form.buttons.clear"])
              }
              whitespace
              button(type: "submit", class: "button_filter btn btn-secondary") {
                TinyAdmin.settings.helper_class.label_for("Filter", options: ["components.filters_form.buttons.submit"])
              }
            }
          }
        end

        private

        def render_boolean_filter(name, filter)
          select(class: "form-select", id: "filter-#{name}", name: "q[#{name}]") {
            option(value: "") { "-" }
            option(value: "0", selected: filter[:value] == "0") {
              TinyAdmin.settings.helper_class.label_for("false", options: ["components.filters_form.boolean.false"])
            }
            option(value: "1", selected: filter[:value] == "1") {
              TinyAdmin.settings.helper_class.label_for("true", options: ["components.filters_form.boolean.true"])
            }
          }
        end

        # Renders two number/date inputs for a min–max range filter.
        # Values are submitted as q[field][gte] and q[field][lte].
        def render_range_filter(name, filter)
          value = filter[:value].is_a?(Hash) ? filter[:value] : {}
          div(class: "d-flex gap-2") {
            input(
              type: "text",
              class: "form-control",
              id: "filter-#{name}-gte",
              name: "q[#{name}][gte]",
              placeholder: TinyAdmin.settings.helper_class.label_for("From", options: ["components.filters_form.range.from"]),
              value: value["gte"] || value[:gte]
            )
            input(
              type: "text",
              class: "form-control",
              id: "filter-#{name}-lte",
              name: "q[#{name}][lte]",
              placeholder: TinyAdmin.settings.helper_class.label_for("To", options: ["components.filters_form.range.to"]),
              value: value["lte"] || value[:lte]
            )
          }
        end

        # Renders a <select>; supports multiple: true for multi-value selection.
        def render_select_filter(name, filter, filter_data)
          multi = filter_data[:multiple]
          current = Array(filter[:value])
          select_attrs = { class: "form-select", id: "filter-#{name}", name: "q[#{name}]" }
          select_attrs[:multiple] = true if multi
          select(**select_attrs) {
            option(value: "") { "-" } unless multi
            filter_data[:values].each do |value|
              option(selected: current.include?(value.to_s)) { value }
            end
          }
        end

        # Renders a <select> whose options come from a related model.
        # Requires filter_data keys: association (class), value_field, label_field.
        def render_association_filter(name, filter, filter_data)
          assoc_class = filter_data[:association]
          value_field = (filter_data[:value_field] || :id).to_sym
          label_field = (filter_data[:label_field] || :name).to_sym
          current = filter[:value].to_s
          records = assoc_class.respond_to?(:all) ? assoc_class.all : []
          select(class: "form-select", id: "filter-#{name}", name: "q[#{name}]") {
            option(value: "") { "-" }
            records.each do |record|
              val = record.public_send(value_field).to_s
              lbl = record.public_send(label_field).to_s
              option(value: val, selected: current == val) { lbl }
            end
          }
        end
      end
    end
  end
end
