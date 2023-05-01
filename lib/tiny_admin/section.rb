# frozen_string_literal: true

module TinyAdmin
  class Section
    attr_reader :name, :options, :path, :slug

    def initialize(name:, slug: nil, path: nil, options: {})
      @name = name
      @options = options
      @path = path || TinyAdmin.route_for(slug)
      @slug = slug
    end
  end
end
