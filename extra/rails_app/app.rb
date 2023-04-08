# frozen_string_literal: true

# --- dependencies -------------------------------------------------------------
begin
  require 'bundler/inline'
rescue LoadError => e
  abort "#{e} - Bundler version 1.10 or later is required. Please update your Bundler"
end

gemfile(true) do
  source 'https://rubygems.org'

  gem 'rails', '~> 7.0'
  gem 'webrick'

  gem 'tiny_admin', path: '../../'
end

# --- Rails application --------------------------------------------------------
require 'action_controller/railtie'
require_relative '../tiny_admin_settings'

class App < Rails::Application
  routes.append do
    root to: proc { [200, {}, ['Root page']] }

    mount TinyAdmin::Router => '/admin'
  end

  config.eager_load = false
end

App.initialize!

Rack::Server.new(app: App, Port: 3000).start
