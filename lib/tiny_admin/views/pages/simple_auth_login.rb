# frozen_string_literal: true

module TinyAdmin
  module Views
    module Pages
      class SimpleAuthLogin < DefaultLayout
        def template
          super do
            div(class: 'simple_auth_login') {
              h1(class: 'title') { title }

              form(class: 'form_login', method: 'post') {
                div(class: 'mt-3') {
                  label(for: 'secret', class: 'form-label') { 'Password' }
                  input(type: 'password', name: 'secret', class: 'form-control', id: 'secret')
                }

                div(class: 'mt-3') {
                  button(type: 'submit', class: 'button_login btn btn-primary') { 'login' }
                }
              }
            }
          end
        end

        def title
          'Login'
        end
      end
    end
  end
end
