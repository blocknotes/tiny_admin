# frozen_string_literal: true

module TinyAdmin
  class BasicApp < Roda
    include Utils

    class << self
      def authentication_plugin
        plugin = TinyAdmin.settings.authentication&.dig(:plugin)
        plugin_class = plugin.is_a?(String) ? Object.const_get(plugin) : plugin
        plugin_class || TinyAdmin::Plugins::NoAuth
      end
    end

    plugin :flash
    plugin :not_found
    plugin :render, engine: 'html'
    plugin :sessions, secret: SecureRandom.hex(64)

    plugin authentication_plugin, TinyAdmin.settings.authentication

    not_found { prepare_page(TinyAdmin.settings.page_not_found).call }
  end
end
