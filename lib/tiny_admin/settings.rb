# frozen_string_literal: true

module TinyAdmin
  class Settings
    include Singleton
    include Utils

    attr_accessor :authentication,
                  :components,
                  :extra_styles,
                  :navbar,
                  :page_not_found,
                  :record_not_found,
                  :repository,
                  :root,
                  :root_path,
                  :sections,
                  :scripts,
                  :style_links

    attr_reader :pages, :resources

    def load_settings
      @authentication ||= {}
      @authentication[:plugin] ||= Plugins::NoAuth
      @authentication[:login] ||= Views::Pages::SimpleAuthLogin
      @authentication[:plugin] = Object.const_get(authentication[:plugin]) if authentication[:plugin].is_a?(String)

      @page_not_found ||= Views::Pages::PageNotFound
      @page_not_found = Object.const_get(@page_not_found) if @page_not_found.is_a?(String)
      @record_not_found ||= Views::Pages::RecordNotFound
      @record_not_found = Object.const_get(@record_not_found) if @record_not_found.is_a?(String)

      @pages ||= {}
      @repository ||= Plugins::ActiveRecordRepository
      @resources ||= {}
      @root_path ||= '/admin'
      @sections ||= []

      @root ||= {}
      @root[:title] ||= 'TinyAdmin'
      @root[:path] ||= root_path
      @root[:page] ||= Views::Pages::Root

      if @authentication[:plugin] == Plugins::SimpleAuth
        @authentication[:logout] ||= ['logout', "#{root_path}/auth/logout"]
      end

      @components ||= {}
      @components[:flash] ||= Views::Components::Flash
      @components[:head] ||= Views::Components::Head
      @components[:navbar] ||= Views::Components::Navbar
      @components[:pagination] ||= Views::Components::Pagination

      @navbar = prepare_navbar(sections, root_path: root_path, logout: authentication[:logout])
    end

    def prepare_navbar(sections, root_path:, logout:)
      items = sections.each_with_object({}) do |section, list|
        slug = section[:slug]
        case section[:type]&.to_sym
        when :url
          list[slug] = [section[:name], section[:url], section[:options]]
        when :page
          page = section[:page]
          pages[slug] = page.is_a?(String) ? Object.const_get(page) : page
          list[slug] = [section[:name], "#{root_path}/#{slug}"]
        when :resource
          repository = section[:repository] || settings.repository
          resources[slug] = {
            model: section[:model].is_a?(String) ? Object.const_get(section[:model]) : section[:model],
            repository: repository.is_a?(String) ? Object.const_get(repository) : repository
          }
          resources[slug].merge! section.slice(:resource, :only, :index, :show, :collection_actions, :member_actions)
          hidden = section[:options] && (section[:options].include?(:hidden) || section[:options].include?('hidden'))
          list[slug] = [section[:name], "#{root_path}/#{slug}"] unless hidden
        end
      end
      items['auth/logout'] = logout if logout
      items
    end
  end
end
