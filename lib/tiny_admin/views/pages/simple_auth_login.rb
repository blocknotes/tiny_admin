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
                  label(for: 'secret', class: 'form-label') {
                    label_for('Password', options: ['pages.simple_auth_login.inputs.password'])
                  }
                  input(type: 'password', name: 'secret', class: 'form-control', id: 'secret')
                }

                div(class: 'mt-3') {
                  button(type: 'submit', class: 'button_login btn btn-primary') {
                    label_for('Login', options: ['pages.simple_auth_login.buttons.submit'])
                  }
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
