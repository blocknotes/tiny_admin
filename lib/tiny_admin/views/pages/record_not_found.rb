# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class RecordNotFound < DefaultLayout
        def view_template
          super do
            div(class: 'record_not_found') {
              h1(class: 'title') { title }
            }
          end
        end

        def title
          'Record not found'
        end
      end
    end
  end
end
