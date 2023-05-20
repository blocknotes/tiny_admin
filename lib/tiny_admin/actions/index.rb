# frozen_string_literal: true

module TinyAdmin
  module Actions
    class Index < BasicAction
      attr_reader :context,
                  :current_page,
                  :fields_options,
                  :links,
                  :options,
                  :pagination,
                  :pages,
                  :params,
                  :query_string,
                  :repository

      def call(app:, context:, options:)
        @context = context
        @options = options || {}
        evaluate_options(options)
        fields = repository.fields(options: fields_options)
        filters = prepare_filters(fields)
        records, count = repository.list(page: current_page, limit: pagination, filters: filters, sort: options[:sort])
        attributes = {
          actions: context.actions,
          fields: fields,
          filters: filters,
          links: options[:links],
          prepare_record: ->(record) { repository.index_record_attrs(record, fields: fields_options) },
          records: records,
          slug: context.slug,
          title: repository.index_title,
          widgets: options[:widgets]
        }

        prepare_page(Views::Actions::Index, slug: context.slug, attributes: attributes) do |page|
          setup_pagination(page, TinyAdmin.settings.components[:pagination], total_count: count)
        end
      end

      private

      def evaluate_options(options)
        @fields_options = attribute_options(options[:attributes])
        @params = context.request.params
        @repository = context.repository
        @pagination = options[:pagination] || 10
        @current_page = (params['p'] || 1).to_i
        @query_string = params_to_s(params.except('p'))
      end

      def prepare_filters(fields)
        filters = (options[:filters] || []).map { _1.is_a?(Hash) ? _1 : { field: _1 } }
        filters = filters.each_with_object({}) { |filter, result| result[filter[:field]] = filter }
        values = (params['q'] || {})
        fields.each_with_object({}) do |(name, field), result|
          result[field] = { value: values[name], filter: filters[name] } if filters.key?(name)
        end
      end

      def setup_pagination(page, pagination_component, total_count:)
        @pages = (total_count / pagination.to_f).ceil
        return if pages <= 1 || !pagination_component

        attributes = { current: current_page, pages: pages, query_string: query_string, total_count: total_count }
        page.pagination_component = pagination_component.new
        page.pagination_component.update_attributes(attributes)
      end
    end
  end
end
