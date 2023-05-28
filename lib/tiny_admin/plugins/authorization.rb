# frozen_string_literal: true

module TinyAdmin
  module Plugins
    class Authorization
      class << self
        def allowed?(_user, _action, _param = nil)
          true
        end
      end
    end
  end
end
