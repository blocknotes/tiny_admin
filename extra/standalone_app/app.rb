# frozen_string_literal: true

# => ruby app.rb

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'

  gem 'rackup'

  gem 'tiny_admin', path: '../../'
end

require_relative '../tiny_admin_settings'

TinyAdmin.configure do |settings|
  settings.root_path = '/'
end

Rackup::Server.new(app: TinyAdmin::Router, Port: 3000).start if __FILE__ == $PROGRAM_NAME
