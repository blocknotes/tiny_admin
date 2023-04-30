# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class Content < DefaultLayout
        def template
          super do
            div(class: 'content') {
              div(class: 'content-data') {
                unsafe_raw(content)
              }

              render TinyAdmin::Views::Components::Widgets.new(widgets) if widgets&.any?
            }
          end
        end
      end
    end
  end
end
