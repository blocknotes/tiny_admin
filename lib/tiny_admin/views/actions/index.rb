# frozen_string_literal: true

module TinyAdmin
  module Views
    module Actions
      class Index < DefaultLayout
        attr_reader :current_page, :fields, :pages, :prepare_record, :records
        attr_accessor :actions, :filters

        def setup_pagination(current_page:, pages:)
          @current_page = current_page
          @pages = pages
        end

        def setup_records(records:, fields:, prepare_record:)
          @records = records
          @fields = fields.index_by(&:name)
          @prepare_record = prepare_record
        end

        def template
          @filters ||= {}

          super do
            div(class: 'index') {
              div(class: 'row') {
                div(class: 'col-4') {
                  h1(class: 'title') { title }
                }
                div(class: 'col-8') {
                  ul(class: 'nav justify-content-end') {
                    (actions || []).each do |action|
                      li(class: 'nav-item') {
                        href = route_for(context.slug, action: action)
                        a(href: href, class: 'nav-link btn btn-outline-secondary') { action }
                      }
                    end
                  }
                }
              }

              div(class: 'row') {
                div_class = filters.any? ? 'col-9' : 'col-12'
                div(class: div_class) {
                  table(class: 'table') {
                    table_header if fields.any?

                    table_body
                  }
                }

                if filters.any?
                  div(class: 'col-3') {
                    filters_form_attrs = { section_path: route_for(context.slug), filters: filters }
                    render TinyAdmin::Views::Components::FiltersForm.new(**filters_form_attrs)
                  }
                end
              }

              if pages
                render components[:pagination].new(current: current_page, pages: pages, query_string: query_string)
              end
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
      end
    end
  end
end
