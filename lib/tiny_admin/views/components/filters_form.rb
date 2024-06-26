# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class FiltersForm < BasicComponent
        attr_accessor :filters, :section_path

        def view_template
          form(class: 'form_filters', method: 'get') {
            filters.each do |field, filter|
              name = field.name
              filter_data = filter[:filter]
              div(class: 'mb-3') {
                label(for: "filter-#{name}", class: 'form-label') { field.title }
                case filter_data[:type]&.to_sym || field.type
                when :boolean
                  select(class: 'form-select', id: "filter-#{name}", name: "q[#{name}]") {
                    option(value: '') { '-' }
                    option(value: '0', selected: filter[:value] == '0') {
                      TinyAdmin.settings.helper_class.label_for('false', options: ['components.filters_form.boolean.false'])
                    }
                    option(value: '1', selected: filter[:value] == '1') {
                      TinyAdmin.settings.helper_class.label_for('true', options: ['components.filters_form.boolean.true'])
                    }
                  }
                when :date
                  input(type: 'date', class: 'form-control', id: "filter-#{name}", name: "q[#{name}]", value: filter[:value])
                when :datetime
                  input(type: 'datetime-local', class: 'form-control', id: "filter-#{name}", name: "q[#{name}]", value: filter[:value])
                when :integer
                  input(type: 'number', class: 'form-control', id: "filter-#{name}", name: "q[#{name}]", value: filter[:value])
                when :select
                  select(class: 'form-select', id: "filter-#{name}", name: "q[#{name}]") {
                    option(value: '') { '-' }
                    filter_data[:values].each do |value|
                      option(selected: filter[:value] == value) { value }
                    end
                  }
                else
                  input(type: 'text', class: 'form-control', id: "filter-#{name}", name: "q[#{name}]", value: filter[:value])
                end
              }
            end

            div(class: 'mt-3') {
              a(href: section_path, class: 'button_clear btn btn-secondary text-white') {
                TinyAdmin.settings.helper_class.label_for('Clear', options: ['components.filters_form.buttons.clear'])
              }
              whitespace
              button(type: 'submit', class: 'button_filter btn btn-secondary') {
                TinyAdmin.settings.helper_class.label_for('Filter', options: ['components.filters_form.buttons.submit'])
              }
            }
          }
        end
      end
    end
  end
end
