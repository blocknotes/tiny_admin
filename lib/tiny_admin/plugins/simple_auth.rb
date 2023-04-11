# frozen_string_literal: true

require 'digest'

module TinyAdmin
  module Plugins
    module SimpleAuth
      class << self
        def configure(app, opts = {})
          @@opts = opts || {} # rubocop:disable Style/ClassVars
          @@opts[:password] ||= ENV.fetch('ADMIN_PASSWORD_HASH', nil) # NOTE: fallback value

          Warden::Strategies.add(:secret) do
            def authenticate!
              secret = params['secret'] || ''
              return fail(:invalid_credentials) if Digest::SHA512.hexdigest(secret) != @@opts[:password]

              success!(app: 'TinyAdmin')
            end
          end

          app.opts[:login_form] = opts[:login_form] || TinyAdmin::Views::Pages::SimpleAuthLogin
          app.use Warden::Manager do |manager|
            manager.default_strategies :secret
            manager.failure_app = TinyAdmin::Authentication
          end
        end
      end

      module InstanceMethods
        def authenticate_user!
          env['warden'].authenticate!
        end

        def current_user
          env['warden'].user
        end

        def logout_user
          env['warden'].logout
        end
      end
    end
  end
end
