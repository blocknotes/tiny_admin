# frozen_string_literal: true

module TinyAdmin
  class Router < BasicApp
    route do |r|
      context.settings = TinyAdmin::Settings.instance
      context.settings.load_settings
      context.router = r

      r.on 'auth' do
        context.slug = nil
        r.run Authentication
      end

      authenticate_user!

      r.root do
        root_route(r)
      end

      r.is do
        # :nocov:
        root_route(r)
        # :nocov:
      end

      r.post '' do
        context.slug = nil
        r.redirect settings.root_path
      end

      context.pages.each do |slug, data|
        setup_page_route(r, slug, data)
      end

      context.resources.each do |slug, options|
        setup_resource_routes(r, slug, options: options || {})
      end

      nil # NOTE: needed to skip the last line (each) return value
    end

    private

    def render_page(page)
      if page.respond_to?(:messages=)
        page.messages = { notices: flash['notices'], warnings: flash['warnings'], errors: flash['errors'] }
      end
      render(inline: page.call)
    end

    def root_route(router)
      context.slug = nil
      if settings.root[:redirect]
        router.redirect route_for(settings.root[:redirect])
      else
        page = settings.root[:page]
        page_class = page.is_a?(String) ? Object.const_get(page) : page
        render_page prepare_page(page_class)
      end
    end

    def setup_page_route(router, slug, page_class)
      router.get slug do
        context.slug = slug
        render_page prepare_page(page_class)
      end
    end

    def setup_resource_routes(router, slug, options:)
      router.on slug do
        context.slug = slug
        setup_collection_routes(router, options: options)
        setup_member_routes(router, options: options)
      end
    end

    def setup_collection_routes(router, options:)
      context.repository = options[:repository].new(options[:model])
      action_options = options[:index] || {}

      # Custom actions
      custom_actions = setup_custom_actions(
        router,
        options[:collection_actions],
        repository: context.repository,
        options: action_options
      )

      # Index
      actions = options[:only]
      if !actions || actions.include?(:index) || actions.include?('index')
        router.is do
          context.request = request
          index_action = TinyAdmin::Actions::Index.new
          render_page index_action.call(app: self, context: context, options: action_options, actions: custom_actions)
        end
      end
    end

    def setup_member_routes(router, options:)
      context.repository = options[:repository].new(options[:model])
      action_options = (options[:show] || {}).merge(record_not_found_page: settings.record_not_found)

      router.on String do |reference|
        context.reference = reference

        # Custom actions
        custom_actions = setup_custom_actions(
          router,
          options[:member_actions],
          repository: context.repository,
          options: action_options
        )

        # Show
        actions = options[:only]
        if !actions || actions.include?(:show) || actions.include?('show')
          router.is do
            context.request = request
            show_action = TinyAdmin::Actions::Show.new
            render_page show_action.call(app: self, context: context, options: action_options, actions: custom_actions)
          end
        end
      end
    end

    def setup_custom_actions(router, custom_actions, repository:, options:)
      context.repository = repository
      (custom_actions || []).each_with_object({}) do |custom_action, result|
        action_slug, action = custom_action.first
        action_class = action.is_a?(String) ? Object.const_get(action) : action

        router.get action_slug.to_s do
          context.request = request
          custom_action = action_class.new
          render_page custom_action.call(app: self, context: context, options: options)
        end

        result[action_slug.to_s] = action_class
      end
    end
  end
end
