# frozen_string_literal: true

module TinyAdmin
  class Router < BasicApp
    extend Forwardable

    def_delegator TinyAdmin, :route_for

    route do |r|
      TinyAdmin.settings.load_settings

      r.on "auth" do
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

      r.post "" do
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
        page.messages = { notices: flash["notices"], warnings: flash["warnings"], errors: flash["errors"] }
      end
      render(inline: page.call)
    end

    def root_route(req)
      authorize!(:root) do
        if TinyAdmin.settings.root[:redirect]
          req.redirect route_for(TinyAdmin.settings.root[:redirect])
        else
          page_class = to_class(TinyAdmin.settings.root[:page])
          attributes = TinyAdmin.settings.root.slice(:content, :title, :widgets)
          render_page prepare_page(page_class, attributes: attributes, params: request.params)
        end
      end
    end

    def setup_page_route(req, slug, page_data)
      req.get slug do
        authorize!(:page, slug) do
          attributes = page_data.slice(:content, :title, :widgets)
          render_page prepare_page(page_data[:class], slug: slug, attributes: attributes, params: request.params)
        end
      end
    end

    def setup_resource_routes(req, slug, options:)
      req.on slug do
        repository = options[:repository].new(options[:model])
        setup_collection_routes(req, slug, options: options, repository: repository)
        setup_member_routes(req, slug, options: options, repository: repository)
      end
    end

    def setup_collection_routes(req, slug, options:, repository:)
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
      if options[:only].include?(:index) || options[:only].include?("index")
        req.is do
          authorize!(:resource_index, slug) do
            context = Context.new(
              actions: custom_actions,
              repository: repository,
              request: request,
              router: req,
              slug: slug
            )
            index_action = TinyAdmin::Actions::Index.new
            render_page index_action.call(app: self, context: context, options: action_options)
          end
        end
      end
    end

    def setup_member_routes(req, slug, options:, repository:)
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
        if options[:only].include?(:show) || options[:only].include?("show")
          req.is do
            authorize!(:resource_show, slug) do
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
            end
          end
        end
      end
    end

    def setup_custom_actions(req, custom_actions = nil, options:, repository:, slug:, reference: nil)
      (custom_actions || []).each_with_object({}) do |custom_action, result|
        action_slug, action_config = custom_action.first
        action_class, http_method = parse_action_config(action_config)

        req.public_send(http_method, action_slug.to_s) do
          authorize!(:custom_action, action_slug.to_s) do
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
          end
        end

        result[action_slug.to_s] = action_class
      end
    end

    def parse_action_config(config)
      if config.is_a?(Hash)
        action_class = to_class(config[:action] || config["action"])
        http_method = (config[:method] || config["method"] || "get").to_sym
        [action_class, http_method]
      else
        [to_class(config), :get]
      end
    end

    def authorization
      TinyAdmin.settings.authorization_class
    end

    def authorize!(action, param = nil)
      if authorization.allowed?(current_user, action, param)
        yield
      else
        render_page prepare_page(TinyAdmin.settings.page_not_allowed)
      end
    end
  end
end
