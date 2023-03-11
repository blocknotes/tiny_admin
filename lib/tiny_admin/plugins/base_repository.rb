# frozen_string_literal: true

module TinyAdmin
  module Plugins
    class BaseRepository
      RecordNotFound = Class.new(StandardError)

      attr_reader :model

      def initialize(model)
        @model = model
      end
    end
  end
end
