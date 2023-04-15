# frozen_string_literal: true

module TinyAdmin
  class Context
    include Singleton

    attr_accessor :reference, :router, :settings, :slug
  end
end
