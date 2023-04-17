# frozen_string_literal: true

module TinyAdmin
  module Views
    module Actions
      class Index < DefaultLayout
        attr_accessor :actions, :fields, :filters, :pagination_component, :prepare_record, :records

        def template
          super do
            div(class: 'index') {
              div(class: 'row') {
                div(class: 'col-4') {
                  h1(class: 'title') { title }
                }
                div(class: 'col-8') {
                  actions_buttons
                }
              }

              div(class: 'row') {
                div_class = filters&.any? ? 'col-9' : 'col-12'
                div(class: div_class) {
                  table(class: 'table') {
                    table_header if fields.any?

                    table_body
                  }
                }

                if filters&.any?
                  div(class: 'col-3') {
                    filters_form_attrs = { section_path: route_for(context.slug), filters: filters }
                    render TinyAdmin::Views::Components::FiltersForm.new(**filters_form_attrs)
                  }
                end
              }

              render pagination_component if pagination_component
            }
          end
        end

        private

        def table_header
          thead {
            tr {
              fields.each_value do |field|
                td(class: "field-header-#{field.name} field-header-type-#{field.type}") { field.title }
              end
              td { whitespace }
            }
          }
        end

        def table_body
          tbody {
            records.each_with_index do |record, index|
              tr(class: "row_#{index + 1}") {
                attributes = prepare_record.call(record)
                attributes.each do |key, value|
                  field = fields[key]
                  td(class: "field-value-#{field.name} field-value-type-#{field.type}") {
                    if field.options && field.options[:link_to]
                      reference = record.send(field.options[:field])
                      a(href: route_for(field.options[:link_to], reference: reference)) { value }
                    else
                      value
                    end
                  }
                end
                td(class: 'actions') {
                  a(href: route_for(context.slug, reference: record.id)) { 'show' }
                }
              }
            end
          }
        end

        def actions_buttons
          ul(class: 'nav justify-content-end') {
            (actions || {}).each do |action, action_class|
              li(class: 'nav-item mx-1') {
                href = route_for(context.slug, action: action)
                title = action_class.respond_to?(:title) ? action_class.title : action
                a(href: href, class: 'nav-link btn btn-outline-secondary') { title }
              }
            end
          }
        end
      end
    end
  end
end
