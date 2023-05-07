# frozen_string_literal: true

require 'bundler'
Bundler.require

require_relative '../tiny_admin_settings'

class RodaApp < Roda
  route do |r|
    r.root do
      'Root page'
    end

    r.on 'admin' do
      r.run TinyAdmin::Router
    end
  end
end

Rackup::Server.new(app: RodaApp, Port: 3000).start if __FILE__ == $PROGRAM_NAME
