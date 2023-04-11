# frozen_string_literal: true

module TinyAdmin
  module Actions
    class Index < BasicAction
      attr_reader :current_page, :fields_options, :filters_list, :pagination, :query_string, :sort

      def call(app:, context:, options:, actions:)
        evaluate_options(options)
        fields = repository.fields(options: fields_options)
        filters = prepare_filters(fields, filters_list)
        records, total_count = repository.list(page: current_page, limit: pagination, filters: filters, sort: sort)
        prepare_record = ->(record) { repository.index_record_attrs(record, fields: fields_options) }
        title = repository.index_title
        pages = (total_count / pagination.to_f).ceil

        prepare_page(Views::Actions::Index, context: context) do |page|
          page.setup_pagination(current_page: current_page, pages: pages > 1 ? pages : false)
          page.setup_records(records: records, fields: fields, prepare_record: prepare_record)
          page.update_attributes(actions: actions, filters: filters, query_string: query_string, title: title)
        end
      end

      private

      def evaluate_options(options)
        @fields_options = options[:attributes]&.each_with_object({}) do |field, result|
          result.merge!(field.is_a?(Hash) ? { field[:field] => field } : { field => { field: field } })
        end
        @filters_list = options[:filters]
        @pagination = options[:pagination] || 10
        @sort = options[:sort] || ['id']

        @current_page = (params['p'] || 1).to_i
        @query_string = params_to_s(params.except('p'))
      end

      def prepare_filters(fields, filters_list)
        filters = (filters_list || []).map { _1.is_a?(Hash) ? _1 : { field: _1 } }
        filters = filters.each_with_object({}) { |filter, result| result[filter[:field]] = filter }
        values = (params['q'] || {})
        fields.each_with_object({}) do |field, result|
          result[field] = { value: values[field.name], filter: filters[field.name] } if filters.key?(field.name)
        end
      end
    end
  end
end
