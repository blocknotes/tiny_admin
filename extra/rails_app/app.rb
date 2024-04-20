# frozen_string_literal: true

# => ruby app.rb

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'

  gem 'rails', '~> 7'
  gem 'tiny_admin', path: '../../'
end

require 'action_controller/railtie'
require_relative '../tiny_admin_settings'

class RailsApp < Rails::Application
  routes.append do
    root to: proc { [200, {}, ['Root page - go to /admin for TinyAdmin']] }

    mount TinyAdmin::Router => '/admin'
  end

  config.action_dispatch.show_exceptions = :none
  config.active_support.cache_format_version = 7.1
  config.consider_all_requests_local = false
  config.eager_load = false
end

RailsApp.initialize!

Rack::Server.new(app: RailsApp, Port: 3000).start if __FILE__ == $PROGRAM_NAME
