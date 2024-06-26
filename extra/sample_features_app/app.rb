# frozen_string_literal: true

# => bundle exec ruby app.rb

require 'bundler'
Bundler.require

TinyAdmin.configure_from_file('./tiny_admin.yml')
Dir[File.expand_path('admin/**/*.rb', __dir__)].each { |f| require f }

Rackup::Server.new(app: TinyAdmin::Router, Port: 3000).start if __FILE__ == $PROGRAM_NAME
