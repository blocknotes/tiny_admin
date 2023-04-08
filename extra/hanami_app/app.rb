# frozen_string_literal: true

# --- dependencies -------------------------------------------------------------
begin
  require 'bundler/inline'
rescue LoadError => e
  abort "#{e} - Bundler version 1.10 or later is required. Please update your Bundler"
end

gemfile(true) do
  source 'https://rubygems.org'

  gem 'rack'
  gem 'webrick'

  gem 'hanami-router'

  gem 'tiny_admin', path: '../../'
end

# --- Hanami application -------------------------------------------------------
require_relative '../tiny_admin_settings'

app = Hanami::Router.new do
  root to: ->(_env) { [200, {}, ['Root page']] }

  mount TinyAdmin::Router, at: '/admin'
end

Rack::Server.new(app: app, Port: 3000).start
