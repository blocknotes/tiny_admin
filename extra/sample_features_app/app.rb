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

  gem 'tiny_admin', path: '../../'
end

# --- Sample features application ----------------------------------------------
Dir[File.expand_path('admin/**/*.rb', __dir__)].each { |f| require f }

TinyAdmin.configure_from_file('./tiny_admin.yml')

Rackup::Server.new(app: TinyAdmin::Router, Port: 3000).start
