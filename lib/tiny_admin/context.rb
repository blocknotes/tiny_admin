# frozen_string_literal: true

module TinyAdmin
  class Context
    include Singleton

    attr_accessor :reference, :repository, :request, :router, :settings, :slug
  end
end
