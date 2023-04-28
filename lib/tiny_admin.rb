# frozen_string_literal: true

require 'phlex'
require 'roda'
require 'zeitwerk'

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

  def settings
    TinyAdmin::Settings.instance
  end

  module_function :configure, :configure_from_file, :settings
end
