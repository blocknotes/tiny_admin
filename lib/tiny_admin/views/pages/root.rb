# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class Root < DefaultLayout
        def template
          super do
            div(class: 'root') {
              h1(class: 'title') { 'Tiny Admin' }
            }
          end
        end
      end
    end
  end
end
