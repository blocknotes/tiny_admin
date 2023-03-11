# frozen_string_literal: true

module TinyAdmin
  class Authentication < BasicApp
    route do |r|
      r.get 'unauthenticated' do
        if current_user
          r.redirect settings.root_path
        else
          render_login
        end
      end

      r.post 'unauthenticated' do
        render_login(warnings: ['Failed to authenticate'])
      end

      r.get 'logout' do
        logout_user
        r.redirect settings.root_path
      end
    end

    private

    def render_login(notices: nil, warnings: nil, errors: nil)
      page = prepare_page(settings.authentication[:login], options: %i[no_menu compact_layout])
      page.setup_flash_messages(
        notices: notices || flash['notices'],
        warnings: warnings || flash['warnings'],
        errors: errors || flash['errors']
      )
      render(inline: page.call)
    end
  end
end
