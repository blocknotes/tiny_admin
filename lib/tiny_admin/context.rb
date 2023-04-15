# frozen_string_literal: true

module TinyAdmin
  class Context
    include Singleton

    attr_accessor :reference, :router, :slug
  end
end
