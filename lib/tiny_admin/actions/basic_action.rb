# frozen_string_literal: true

module TinyAdmin
  module Actions
    class BasicAction
      include Utils

      attr_reader :params, :repository

      def initialize(repository, params:)
        @repository = repository
        @params = params
      end
    end
  end
end
