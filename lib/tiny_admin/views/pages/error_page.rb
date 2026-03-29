# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class ErrorPage < DefaultLayout
        def view_template
          super do
            div(class: css_class) {
              h1(class: "title") { title }
            }
          end
        end

        private

        def css_class
          self.class.name.split("::").last
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .downcase
        end
      end
    end
  end
end
