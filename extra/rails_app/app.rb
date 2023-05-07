# frozen_string_literal: true

require 'bundler'
Bundler.require

require 'action_controller/railtie'
require_relative '../tiny_admin_settings'

class RailsApp < Rails::Application
  routes.append do
    root to: proc { [200, {}, ['Root page']] }

    mount TinyAdmin::Router => '/admin'
  end

  config.eager_load = false
end

RailsApp.initialize!

Rack::Server.new(app: RailsApp, Port: 3000).start if __FILE__ == $PROGRAM_NAME
