# frozen_string_literal: true

module TinyAdmin
  class BasicApp < Roda
    include Utils

    class << self
      include Utils

      def authentication_plugin
        plugin = TinyAdmin.settings.authentication&.dig(:plugin)
        plugin_class = to_class(plugin) if plugin
        plugin_class || TinyAdmin::Plugins::NoAuth
      end
    end

    plugin :flash
    plugin :not_found
    plugin :render, engine: "html"
    plugin :sessions, secret: ENV.fetch("TINY_ADMIN_SECRET") { SecureRandom.hex(64) }

    # NOTE: The authentication plugin is applied at class-load time.  Ensure
    # TinyAdmin.configure / TinyAdmin.configure_from_file are called before
    # BasicApp (or its subclass Router) is first referenced.
    plugin authentication_plugin, TinyAdmin.settings.authentication

    not_found { prepare_page(TinyAdmin.settings.page_not_found).call }
  end
end
