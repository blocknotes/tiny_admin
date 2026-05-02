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
        sort = merge_sort(options[:sort], fields)
        records, count = repository.list(page: current_page, limit: pagination, filters: filters, sort: sort)
        attributes = {
          actions: context.actions,
          fields: fields,
          filters: filters,
          links: options[:links],
          prepare_record: ->(record) { repository.index_record_attrs(record, fields: fields_options) },
          records: records,
          show_link: options.fetch(:show_link, true),
          slug: context.slug,
          sort_params: @sort_params,
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
        @current_page = (params["p"] || 1).to_i
        @query_string = params_to_s(params.except("p", "sort"))
        @sort_params = params["sort"]
      end

      # Merge user-supplied sort params (from query string) with the configured
      # sort defaults.  Only fields that are actually returned by the repository
      # are accepted to prevent arbitrary column injection.
      def merge_sort(configured_sort, fields)
        raw = params["sort"]
        return configured_sort unless raw.is_a?(Hash)

        allowed = fields.keys.map(&:to_s)
        dynamic = raw.each_with_object([]) do |(field, dir), list|
          next unless allowed.include?(field.to_s)

          direction = dir.to_s.downcase == "desc" ? "DESC" : "ASC"
          list << "#{field} #{direction}"
        end
        dynamic.any? ? dynamic : configured_sort
      end

      def prepare_filters(fields)
        filters = (options[:filters] || []).map { _1.is_a?(Hash) ? _1 : { field: _1 } }
        filters = filters.to_h { |filter| [filter[:field], filter] }
        values = params["q"] || {}
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
