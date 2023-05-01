# frozen_string_literal: true

module TinyAdmin
  module Views
    module Actions
      class Show < DefaultLayout
        attr_accessor :actions, :fields, :prepare_record, :record, :reference, :slug

        def template
          super do
            div(class: 'show') {
              div(class: 'row') {
                div(class: 'col-4') {
                  h1(class: 'title') { title }
                }
                div(class: 'col-8') {
                  actions_buttons
                }
              }

              prepare_record.call(record).each do |key, value|
                field = fields[key]
                div(class: "field-#{field.name} row lh-lg") {
                  if field
                    div(class: 'field-header col-2') { field.options[:header] || field.title }
                  end
                  div(class: 'field-value col-10') {
                    if field.options[:link_to]
                      a(href: TinyAdmin.route_for(field.options[:link_to], reference: value)) {
                        field.apply_call_option(record) || value
                      }
                    else
                      value
                    end
                  }
                }
              end

              render TinyAdmin::Views::Components::Widgets.new(widgets)
            }
          end
        end

        private

        def actions_buttons
          ul(class: 'nav justify-content-end') {
            (actions || {}).each do |action, action_class|
              li(class: 'nav-item mx-1') {
                href = TinyAdmin.route_for(slug, reference: reference, action: action)
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
