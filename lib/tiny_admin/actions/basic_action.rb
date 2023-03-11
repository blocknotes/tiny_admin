# frozen_string_literal: true

module TinyAdmin
  module Actions
    class BasicAction
      include Utils

      attr_reader :params, :path, :repository

      def initialize(repository, path:, params:)
        @repository = repository
        @path = path
        @params = params
      end
    end
  end
end
