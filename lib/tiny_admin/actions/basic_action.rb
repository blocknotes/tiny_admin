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

      def attribute_options(options)
        options&.each_with_object({}) do |field, result|
          field_data =
            if field.is_a?(Hash)
              if field.one?
                field, method = field.first
                { field.to_s => { field: field.to_s, method: method } }
              else
                { field[:field] => field }
              end
            else
              { field => { field: field } }
            end
          result.merge!(field_data)
        end
      end
    end
  end
end
