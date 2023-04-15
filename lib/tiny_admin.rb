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
    block&.call(TinyAdmin::Settings.instance) || TinyAdmin::Settings.instance
  end

  def configure_from_file(file)
    config = YAML.load_file(file, symbolize_names: true)
    config.each do |key, value|
      TinyAdmin::Settings.instance[key] = value
    end
  end

  module_function :configure, :configure_from_file
end
