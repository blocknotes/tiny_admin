# frozen_string_literal: true

module TinyAdmin
  class BasicApp < Roda
    include Utils

    plugin :flash
    plugin :not_found
    plugin :render, engine: 'html'
    plugin :sessions, secret: SecureRandom.hex(64)

    plugin TinyAdmin.settings.authentication[:plugin], TinyAdmin.settings.authentication

    not_found { prepare_page(TinyAdmin.settings.page_not_found).call }
  end
end
