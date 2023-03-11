# frozen_string_literal: true

module TinyAdmin
  module Plugins
    module NoAuth
      class << self
        def configure(_app, _opts = {}); end
      end

      module InstanceMethods
        def authenticate_user!
          true
        end

        def current_user
          'admin'
        end

        def logout_user
          nil
        end
      end
    end
  end
end
