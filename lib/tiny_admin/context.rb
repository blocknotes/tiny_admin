# frozen_string_literal: true

module TinyAdmin
  class Context
    include Singleton

    attr_accessor :actions,
                  :navbar,
                  :pages,
                  :reference,
                  :repository,
                  :request,
                  :resources,
                  :router,
                  :settings,
                  :slug
  end
end
