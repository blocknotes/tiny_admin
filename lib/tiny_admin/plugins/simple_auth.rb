# frozen_string_literal: true

require "digest"

module TinyAdmin
  module Plugins
    # SimpleAuth provides session-based password authentication via Warden.
    #
    # Configuration options:
    #   password        - Password hash.  Accepts:
    #                       * BCrypt hash (starts with "$2b$" or "$2a$") – recommended.
    #                       * SHA-512 hex digest – kept for backward compatibility
    #                         (deprecated; prefer BCrypt).
    #   username        - Optional plain-text username.  When set the login form must
    #                     provide a matching "username" param in addition to "secret".
    #   max_attempts    - Max failed login attempts before lockout (default: 5).
    #   lockout_seconds - Seconds to lock out after max_attempts (default: 300).
    #
    # Disclaimer: this plugin is provided as an example.  For production use,
    # implement your own authentication backed by a proper user model.
    module SimpleAuth
      # BCrypt hash prefixes (2a, 2b, 2y are all valid bcrypt identifiers).
      BCRYPT_PREFIX = /\A\$2[aby]\$/

      class << self
        def configure(app, opts = {})
          opts ||= {}
          config = extract_config(opts)
          register_warden_strategy(config)
          configure_warden_manager(app, opts)
        end

        # Exposed for use inside the Warden strategy block.
        def password_valid?(secret, password_hash)
          return false unless password_hash

          if password_hash.match?(BCRYPT_PREFIX)
            require "bcrypt"
            BCrypt::Password.new(password_hash).is_password?(secret)
          else
            Digest::SHA512.hexdigest(secret) == password_hash
          end
        end

        private

        def extract_config(opts)
          {
            password_hash: opts[:password] || ENV.fetch("ADMIN_PASSWORD_HASH", nil),
            username: opts[:username] || ENV.fetch("ADMIN_USERNAME", nil),
            max_attempts: (opts[:max_attempts] || 5).to_i,
            lockout_seconds: (opts[:lockout_seconds] || 300).to_i
          }
        end

        def register_warden_strategy(config)
          Warden::Strategies.add(:secret) do
            define_method(:authenticate!) do
              rate_check(config) && username_check(config) && password_check(config)
            end

            define_method(:rate_check) do |_cfg|
              locked_until = env["rack.session"]["tiny_admin_locked_until"]
              return fail!(:locked_out) if locked_until && Time.now.to_i < locked_until

              true
            end

            define_method(:username_check) do |cfg|
              return true unless cfg[:username]
              return fail!(:invalid_credentials) if params["username"].to_s != cfg[:username]

              true
            end

            define_method(:password_check) do |cfg|
              secret = params["secret"].to_s
              if SimpleAuth.password_valid?(secret, cfg[:password_hash])
                env["rack.session"].delete("tiny_admin_failed_attempts")
                env["rack.session"].delete("tiny_admin_locked_until")
                success!(app: "TinyAdmin")
              else
                record_failed_attempt(cfg)
              end
            end

            define_method(:record_failed_attempt) do |cfg|
              attempts = env["rack.session"]["tiny_admin_failed_attempts"].to_i + 1
              if attempts >= cfg[:max_attempts]
                env["rack.session"]["tiny_admin_locked_until"] = Time.now.to_i + cfg[:lockout_seconds]
                env["rack.session"].delete("tiny_admin_failed_attempts")
                fail!(:locked_out)
              else
                env["rack.session"]["tiny_admin_failed_attempts"] = attempts
                fail!(:invalid_credentials)
              end
            end
          end
        end

        def configure_warden_manager(app, opts)
          app.opts[:login_form] = opts[:login_form] || TinyAdmin::Views::Pages::SimpleAuthLogin
          app.use Warden::Manager do |manager|
            manager.default_strategies :secret
            manager.failure_app = TinyAdmin::Authentication
          end
        end
      end

      module InstanceMethods
        def authenticate_user!
          env["warden"].authenticate!
        end

        def current_user
          env["warden"].user
        end

        def logout_user
          env["warden"].logout
        end
      end
    end
  end
end
