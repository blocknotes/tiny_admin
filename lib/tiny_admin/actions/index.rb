# frozen_string_literal: true

module TinyAdmin
  module Actions
    class Index < BasicAction
      attr_reader :current_page,
                  :fields_options,
                  :filters_list,
                  :pagination,
                  :pages,
                  :params,
                  :query_string,
                  :repository,
                  :sort

      def call(app:, context:, options:)
        evaluate_options(options)
        fields = repository.fields(options: fields_options)
        filters = prepare_filters(fields, filters_list)
        records, total_count = repository.list(page: current_page, limit: pagination, filters: filters, sort: sort)

        prepare_page(Views::Actions::Index) do |page|
          setup_pagination(page, settings.components[:pagination], total_count: total_count)
          page.update_attributes(
            actions: context.actions,
            fields: fields,
            filters: filters,
            prepare_record: ->(record) { repository.index_record_attrs(record, fields: fields_options) },
            records: records,
            title: repository.index_title
          )
        end
      end

      private

      def evaluate_options(options)
        @fields_options = attribute_options(options[:attributes])
        @params = context.request.params
        @repository = context.repository
        @filters_list = options[:filters]
        @pagination = options[:pagination] || 10
        @sort = options[:sort]

        @current_page = (params['p'] || 1).to_i
        @query_string = params_to_s(params.except('p'))
      end

      def prepare_filters(fields, filters_list)
        filters = (filters_list || []).map { _1.is_a?(Hash) ? _1 : { field: _1 } }
        filters = filters.each_with_object({}) { |filter, result| result[filter[:field]] = filter }
        values = (params['q'] || {})
        fields.each_with_object({}) do |(name, field), result|
          result[field] = { value: values[name], filter: filters[name] } if filters.key?(name)
        end
      end

      def setup_pagination(page, pagination_component_class, total_count:)
        @pages = (total_count / pagination.to_f).ceil
        return if pages <= 1 || !pagination_component_class

        page.pagination_component = pagination_component_class.new
        page.pagination_component.update_attributes(current: current_page, pages: pages, query_string: query_string)
      end
    end
  end
end
