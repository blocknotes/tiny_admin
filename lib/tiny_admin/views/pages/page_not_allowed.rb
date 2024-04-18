# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class PageNotAllowed < DefaultLayout
        def view_template
          super do
            div(class: 'page_not_allowed') {
              h1(class: 'title') { title }
            }
          end
        end

        def title
          'Page not allowed'
        end
      end
    end
  end
end
