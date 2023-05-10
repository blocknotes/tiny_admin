# frozen_string_literal: true
# typed: true

require 'phlex'
require 'roda'
require 'zeitwerk'

require 'forwardable'
require 'singleton'
require 'yaml'

loader = Zeitwerk::Loader.for_gem
loader.setup

module TinyAdmin
  def configure(&block)
    block&.call(settings) || settings
  end

  def configure_from_file(file)
    settings.reset!
    config = YAML.load_file(file, symbolize_names: true)
    config.each do |key, value|
      settings[key] = value
    end
  end

  def route_for(section, reference: nil, action: nil, query: nil)
    root_path = settings.root_path == '/' ? nil : settings.root_path
    route = [root_path, section, reference, action].compact.join("/")
    route << "?#{query}" if query
    route[0] == '/' ? route : route.prepend('/')
  end

  def settings
    TinyAdmin::Settings.instance
  end

  module_function :configure, :configure_from_file, :route_for, :settings
end
