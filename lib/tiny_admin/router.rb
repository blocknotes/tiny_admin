# frozen_string_literal: true

module TinyAdmin
  class Router < BasicApp
    extend Forwardable

    def_delegator TinyAdmin, :route_for

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

    def root_route(req)
      if authorization.allowed?(current_user, :root)
        if TinyAdmin.settings.root[:redirect]
          req.redirect route_for(TinyAdmin.settings.root[:redirect])
        else
          page_class = to_class(TinyAdmin.settings.root[:page])
          attributes = TinyAdmin.settings.root.slice(:content, :title, :widgets)
          render_page prepare_page(page_class, attributes: attributes, params: request.params)
        end
      else
        render_page prepare_page(TinyAdmin.settings.page_not_allowed)
      end
    end

    def setup_page_route(req, slug, page_data)
      req.get slug do
        if authorization.allowed?(current_user, :page, slug)
          attributes = page_data.slice(:content, :title, :widgets)
          render_page prepare_page(page_data[:class], slug: slug, attributes: attributes, params: request.params)
        else
          render_page prepare_page(TinyAdmin.settings.page_not_allowed)
        end
      end
    end

    def setup_resource_routes(req, slug, options:)
      req.on slug do
        setup_collection_routes(req, slug, options: options)
        setup_member_routes(req, slug, options: options)
      end
    end

    def setup_collection_routes(req, slug, options:)
      repository = options[:repository].new(options[:model])
      action_options = options[:index] || {}

      # Custom actions
      custom_actions = setup_custom_actions(
        req,
        options[:collection_actions],
        options: action_options,
        repository: repository,
        slug: slug
      )

      # Index
      if options[:only].include?(:index) || options[:only].include?('index')
        req.is do
          if authorization.allowed?(current_user, :resource_index, slug)
            context = Context.new(
              actions: custom_actions,
              repository: repository,
              request: request,
              router: req,
              slug: slug
            )
            index_action = TinyAdmin::Actions::Index.new
            render_page index_action.call(app: self, context: context, options: action_options)
          else
            render_page prepare_page(TinyAdmin.settings.page_not_allowed)
          end
        end
      end
    end

    def setup_member_routes(req, slug, options:)
      repository = options[:repository].new(options[:model])
      action_options = (options[:show] || {}).merge(record_not_found_page: TinyAdmin.settings.record_not_found)

      req.on String do |reference|
        # Custom actions
        custom_actions = setup_custom_actions(
          req,
          options[:member_actions],
          options: action_options,
          repository: repository,
          slug: slug,
          reference: reference
        )

        # Show
        if options[:only].include?(:show) || options[:only].include?('show')
          req.is do
            if authorization.allowed?(current_user, :resource_show, slug)
              context = Context.new(
                actions: custom_actions,
                reference: reference,
                repository: repository,
                request: request,
                router: req,
                slug: slug
              )
              show_action = TinyAdmin::Actions::Show.new
              render_page show_action.call(app: self, context: context, options: action_options)
            else
              render_page prepare_page(TinyAdmin.settings.page_not_allowed)
            end
          end
        end
      end
    end

    def setup_custom_actions(req, custom_actions = nil, options:, repository:, slug:, reference: nil)
      (custom_actions || []).each_with_object({}) do |custom_action, result|
        action_slug, action = custom_action.first
        action_class = to_class(action)

        req.get action_slug.to_s do
          if authorization.allowed?(current_user, :custom_action, action_slug.to_s)
            context = Context.new(
              actions: {},
              reference: reference,
              repository: repository,
              request: request,
              router: req,
              slug: slug
            )
            custom_action = action_class.new
            render_page custom_action.call(app: self, context: context, options: options)
          else
            render_page prepare_page(TinyAdmin.settings.page_not_allowed)
          end
        end

        result[action_slug.to_s] = action_class
      end
    end

    def authorization
      TinyAdmin.settings.authorization_class
    end
  end
end
