# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class PageNotFound < DefaultLayout
        def view_template
          super do
            div(class: 'page_not_found') {
              h1(class: 'title') { title }
            }
          end
        end

        def title
          'Page not found'
        end
      end
    end
  end
end
