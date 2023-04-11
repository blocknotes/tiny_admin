# frozen_string_literal: true

require 'bundler'
Bundler.require

Dir[File.expand_path('admin/**/*.rb', __dir__)].each { |f| require f }
TinyAdmin.configure_from_file('./tiny_admin.yml')

Rackup::Server.new(app: TinyAdmin::Router, Port: 3000).start if __FILE__ == $PROGRAM_NAME
