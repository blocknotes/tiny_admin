# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class ActionsButtons < BasicComponent
        attr_accessor :actions, :slug, :reference

        def view_template
          ul(class: "nav justify-content-end") {
            (actions || {}).each do |action, action_class|
              li(class: "nav-item mx-1") {
                href = TinyAdmin.route_for(slug, reference: reference, action: action)
                a(href: href, class: "nav-link btn btn-outline-secondary") {
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
