# frozen_string_literal: true

module TinyAdmin
  class Authentication < BasicApp
    route do |r|
      r.get 'unauthenticated' do
        if current_user
          r.redirect TinyAdmin.settings.root_path
        else
          render_login
        end
      end

      r.post 'unauthenticated' do
        warning = TinyAdmin.settings.helper_class.label_for(
          'Failed to authenticate',
          options: ['authentication.unauthenticated']
        )
        render_login(warnings: [warning])
      end

      r.get 'logout' do
        logout_user
        r.redirect TinyAdmin.settings.root_path
      end
    end

    private

    def render_login(notices: nil, warnings: nil, errors: nil)
      login = TinyAdmin.settings.authentication[:login]
      return unless login

      page = prepare_page(login, options: %i[no_menu compact_layout])
      page.messages = {
        notices: notices || flash['notices'],
        warnings: warnings || flash['warnings'],
        errors: errors || flash['errors']
      }
      render(inline: page.call)
    end
  end
end
