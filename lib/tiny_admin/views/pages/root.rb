# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class Root < DefaultLayout
        def view_template
          super do
            div(class: 'root') {
              render TinyAdmin::Views::Components::Widgets.new(widgets)
            }
          end
        end
      end
    end
  end
end
