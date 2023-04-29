# frozen_string_literal: true

module TinyAdmin
  class Router < BasicApp
    route do |r|
      TinyAdmin.settings.load_settings

      r.on 'auth' do
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
        r.redirect TinyAdmin.settings.root_path
      end

      store.pages.each do |slug, page_data|
        setup_page_route(r, slug, page_data)
      end

      store.resources.each do |slug, options|
        setup_resource_routes(r, slug, options: options || {})
      end

      nil # NOTE: needed to skip the last line (each) return value
    end

    private

    def store
      @store ||= TinyAdmin.settings.store
    end

    def render_page(page)
      if page.respond_to?(:messages=)
        page.messages = { notices: flash['notices'], warnings: flash['warnings'], errors: flash['errors'] }
      end
      render(inline: page.call)
    end

    def root_route(router)
      if TinyAdmin.settings.root[:redirect]
        router.redirect route_for(TinyAdmin.settings.root[:redirect])
      else
        page = TinyAdmin.settings.root[:page]
        page_class = page.is_a?(String) ? Object.const_get(page) : page
        render_page prepare_page(page_class)
      end
    end

    def setup_page_route(router, slug, page_data)
      router.get slug do
        page = prepare_page(page_data[:class], slug: slug)
        page.update_attributes(content: page_data[:content]) if page_data[:content]
        render_page page
      end
    end

    def setup_resource_routes(router, slug, options:)
      router.on slug do
        setup_collection_routes(router, slug, options: options)
        setup_member_routes(router, slug, options: options)
      end
    end

    def setup_collection_routes(router, slug, options:)
      repository = options[:repository].new(options[:model])
      action_options = options[:index] || {}

      # Custom actions
      custom_actions = setup_custom_actions(
        router,
        options[:collection_actions],
        options: action_options,
        repository: repository,
        slug: slug
      )

      # Index
      if options[:only].include?(:index) || options[:only].include?('index')
        router.is do
          context = Context.new(
            actions: custom_actions,
            repository: repository,
            request: request,
            router: router,
            slug: slug
          )
          index_action = TinyAdmin::Actions::Index.new
          render_page index_action.call(app: self, context: context, options: action_options)
        end
      end
    end

    def setup_member_routes(router, slug, options:)
      repository = options[:repository].new(options[:model])
      action_options = (options[:show] || {}).merge(record_not_found_page: TinyAdmin.settings.record_not_found)

      router.on String do |reference|
        # Custom actions
        custom_actions = setup_custom_actions(
          router,
          options[:member_actions],
          options: action_options,
          repository: repository,
          slug: slug,
          reference: reference
        )

        # Show
        if options[:only].include?(:show) || options[:only].include?('show')
          router.is do
            context = Context.new(
              actions: custom_actions,
              reference: reference,
              repository: repository,
              request: request,
              router: router,
              slug: slug
            )
            show_action = TinyAdmin::Actions::Show.new
            render_page show_action.call(app: self, context: context, options: action_options)
          end
        end
      end
    end

    def setup_custom_actions(router, custom_actions, options:, repository:, slug:, reference: nil)
      (custom_actions || []).each_with_object({}) do |custom_action, result|
        action_slug, action = custom_action.first
        action_class = action.is_a?(String) ? Object.const_get(action) : action

        router.get action_slug.to_s do
          context = Context.new(
            actions: {},
            reference: reference,
            repository: repository,
            request: request,
            router: router,
            slug: slug
          )
          custom_action = action_class.new
          render_page custom_action.call(app: self, context: context, options: options)
        end

        result[action_slug.to_s] = action_class
      end
    end
  end
end
