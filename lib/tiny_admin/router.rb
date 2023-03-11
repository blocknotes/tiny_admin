# frozen_string_literal: true

module TinyAdmin
  class Router < BasicApp
    TinyAdmin::Settings.instance.load_settings

    route do |r|
      r.on 'auth' do
        context.slug = nil
        r.run Authentication
      end

      authenticate_user!

      r.root do
        root_route(r)
      end

      r.post '' do
        context.slug = nil
        r.redirect settings.root_path
      end

      TinyAdmin::Settings.instance.pages.each do |slug, data|
        setup_page_route(r, slug, data)
      end

      TinyAdmin::Settings.instance.resources.each do |slug, options|
        setup_resource_routes(r, slug, options: options || {})
      end

      nil # NOTE: needed to skip the last line (each) return value
    end

    private

    def render_page(page)
      attach_flash_messages(page)
      render(inline: page.call)
    end

    def root_route(router)
      context.slug = nil
      if settings.root[:redirect]
        router.redirect "#{settings.root_path}/#{settings.root[:redirect]}"
      else
        page = settings.root[:page]
        page_class = page.is_a?(String) ? Object.const_get(page) : page
        render_page prepare_page(page_class, context: context)
      end
    end

    def setup_page_route(router, slug, page_class)
      router.get slug do
        context.slug = slug
        render_page prepare_page(page_class, context: context)
      end
    end

    def setup_resource_routes(router, slug, options:)
      router.on slug do
        context.slug = slug
        setup_collection_routes(router, slug: slug, options: options)
        setup_member_routes(router, slug: slug, options: options)
      end
    end

    def setup_collection_routes(router, slug:, options:)
      repository = options[:repository].new(options[:model])
      index_options = options[:index] || {}
      custom_actions = []

      # Custom actions
      (options[:collection_actions] || []).each do |custom_action|
        action_slug, action = custom_action.first
        action_class = action.is_a?(String) ? Object.const_get(action) : action
        custom_actions << action_slug.to_s
        router.get action_slug.to_s do
          custom_action = action_class.new(repository, path: request.path, params: request.params)
          render_page custom_action.call(app: self, context: context, options: index_options)
        end
      end

      # Index
      actions = options[:only]
      if !actions || actions.include?(:index) || actions.include?('index')
        router.is do
          index_action = TinyAdmin::Actions::Index.new(repository, path: request.path, params: request.params)
          render_page index_action.call(app: self, context: context, options: index_options, actions: custom_actions)
        end
      end
    end

    def setup_member_routes(router, slug:, options:)
      repository = options[:repository].new(options[:model])
      show_options = (options[:show] || {}).merge(record_not_found_page: settings.record_not_found)
      custom_actions = []

      router.on String do |reference|
        context.reference = reference

        # Custom actions
        (options[:member_actions] || []).each do |custom_action|
          action_slug, action = custom_action.first
          action_class = action.is_a?(String) ? Object.const_get(action) : action
          custom_actions << action_slug.to_s

          router.get action_slug.to_s do
            custom_action = action_class.new(repository, path: request.path, params: request.params)
            render_page custom_action.call(app: self, context: context, options: show_options)
          end
        end

        # Show
        actions = options[:only]
        if !actions || actions.include?(:show) || actions.include?('show')
          router.is do
            show_action = TinyAdmin::Actions::Show.new(repository, path: request.path, params: request.params)
            render_page show_action.call(app: self, context: context, options: show_options, actions: custom_actions)
          end
        end
      end
    end
  end
end
