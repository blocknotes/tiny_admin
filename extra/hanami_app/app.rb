# frozen_string_literal: true

require 'bundler'
Bundler.require

require_relative '../tiny_admin_settings'

app = Hanami::Router.new do
  root to: ->(_env) { [200, {}, ['Root page']] }

  mount TinyAdmin::Router, at: '/admin'
end

Rack::Server.new(app: app, Port: 3000).start if __FILE__ == $PROGRAM_NAME
