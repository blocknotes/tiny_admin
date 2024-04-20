# frozen_string_literal: true

# => ruby app.rb

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'

  gem 'rackup'
  gem 'roda'
  gem 'tiny_admin', path: '../../'
end

require_relative '../tiny_admin_settings'

class RodaApp < Roda
  route do |r|
    r.root do
      'Root page - go to /admin for TinyAdmin'
    end

    r.on 'admin' do
      r.run TinyAdmin::Router
    end
  end
end

Rackup::Server.new(app: RodaApp, Port: 3000).start if __FILE__ == $PROGRAM_NAME
