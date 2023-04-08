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
  gem 'rackup'
  gem 'webrick'

  gem 'roda'

  gem 'tiny_admin', path: '../../'
end

# --- Roda application ---------------------------------------------------------
require_relative '../tiny_admin_settings'

class App < Roda
  route do |r|
    r.root do
      'Root page'
    end

    r.on 'admin' do
      r.run TinyAdmin::Router
    end
  end
end

Rackup::Server.new(app: App, Port: 3000).start
