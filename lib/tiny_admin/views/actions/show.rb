# frozen_string_literal: true

module TinyAdmin
  module Views
    module Actions
      class Show < DefaultLayout
        attr_accessor :actions, :fields, :prepare_record, :record

        def template
          super do
            div(class: 'show') {
              div(class: 'row') {
                div(class: 'col-4') {
                  h1(class: 'title') { title }
                }
                div(class: 'col-8') {
                  ul(class: 'nav justify-content-end') {
                    (actions || {}).each do |action, action_class|
                      li(class: 'nav-item mx-1') {
                        href = route_for(context.slug, reference: context.reference, action: action)
                        title = action_class.respond_to?(:title) ? action_class.title : action
                        a(href: href, class: 'nav-link btn btn-outline-secondary') { title }
                      }
                    end
                  }
                }
              }

              prepare_record.call(record).each do |key, value|
                field = fields[key]
                div(class: "field-#{field.name} row lh-lg") {
                  if field
                    div(class: 'field-header col-2') { field.title }
                  end
                  div(class: 'field-value col-10') {
                    if field.options && field.options[:link_to]
                      reference = record.send(field.options[:field])
                      a(href: route_for(field.options[:link_to], reference: reference)) { value }
                    else
                      value
                    end
                  }
                }
              end
            }
          end
        end
      end
    end
  end
end
