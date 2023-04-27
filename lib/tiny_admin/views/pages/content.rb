# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class Content < DefaultLayout
        def template
          super do
            div(class: 'content') {
              unsafe_raw(content)
            }
          end
        end
      end
    end
  end
end
