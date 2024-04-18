# frozen_string_literal: true

module TinyAdmin
  module Views
    module Actions
      class Index < DefaultLayout
        attr_accessor :actions,
                      :fields,
                      :filters,
                      :links,
                      :pagination_component,
                      :prepare_record,
                      :records,
                      :slug

        def view_template
          super do
            div(class: 'index') {
              div(class: 'row') {
                div(class: 'col-4') {
                  h1(class: 'title') {
                    title
                  }
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

                  render pagination_component if pagination_component
                }

                if filters&.any?
                  div(class: 'col-3') {
                    filters_form = TinyAdmin::Views::Components::FiltersForm.new
                    filters_form.update_attributes(section_path: TinyAdmin.route_for(slug), filters: filters)
                    render filters_form
                  }
                end
              }

              render TinyAdmin::Views::Components::Widgets.new(widgets)
            }
          end
        end

        private

        def table_header
          thead {
            tr {
              fields.each_value do |field|
                td(class: "field-header-#{field.name} field-header-type-#{field.type}") {
                  field.options[:header] || field.title
                }
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
                    render TinyAdmin.settings.components[:field_value].new(field, value, record: record)
                  }
                end

                td(class: 'actions p-1') {
                  div(class: 'btn-group btn-group-sm') {
                    link_class = 'btn btn-outline-secondary'
                    if links
                      links.each do |link|
                        whitespace
                        if link == 'show'
                          a(href: TinyAdmin.route_for(slug, reference: record.id), class: link_class) {
                            label_for('Show', options: ['actions.index.links.show'])
                          }
                        else
                          a(href: TinyAdmin.route_for(slug, reference: record.id, action: link), class: link_class) {
                            fallback = humanize(link)
                            label_for(fallback, options: ["actions.index.links.#{link}"])
                          }
                        end
                      end
                    else
                      a(href: TinyAdmin.route_for(slug, reference: record.id), class: link_class) {
                        label_for('Show', options: ['actions.index.links.show'])
                      }
                    end
                  }
                }
              }
            end
          }
        end

        def actions_buttons
          ul(class: 'nav justify-content-end') {
            (actions || {}).each do |action, action_class|
              li(class: 'nav-item mx-1') {
                href = TinyAdmin.route_for(slug, action: action)
                a(href: href, class: 'nav-link btn btn-outline-secondary') {
                  action_class.respond_to?(:title) ? action_class.title : action
                }
              }
            end
          }
        end
      end
    end
  end
end
