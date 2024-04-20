# frozen_string_literal: true

# => rackup -p 3000

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'

  gem 'hanami-router'
  gem 'webrick'

  gem 'tiny_admin', path: '../../'
end

require 'hanami/router'

require_relative '../tiny_admin_settings'

app = Hanami::Router.new do
  root to: ->(_env) { [200, {}, ['Root page - go to /admin for TinyAdmin']] }

  mount TinyAdmin::Router, at: '/admin'
end

run app
