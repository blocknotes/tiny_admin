# frozen_string_literal: true

require "csv"

module TinyAdmin
  module Actions
    # CsvExport is a collection action that streams all matching records as a
    # CSV file attachment.  It honours the same field/attribute config as the
    # Index action and applies any active filters, but skips pagination so the
    # full dataset is returned.
    #
    # Register it as a collection action in your resource section:
    #
    #   collection_actions:
    #     - csv_export: TinyAdmin::Actions::CsvExport
    #
    # The action respects the resource's +index.attributes+ config for the
    # columns to export.  If no attributes are configured, all repository fields
    # are exported.
    class CsvExport < BasicAction
      def call(app:, context:, options:)
        repository = context.repository
        fields_options = attribute_options(options[:attributes])
        fields = repository.fields(options: fields_options)
        filters = prepare_filters(fields, context.request.params, options)
        records = fetch_all_records(repository, filters, options)

        csv_content = build_csv(records, fields, repository, fields_options)
        set_csv_response_headers(app, context.slug)
        app.render(inline: csv_content)
      end

      private

      def fetch_all_records(repository, filters, options)
        # Fetch all matching records without pagination
        records, = repository.list(page: 1, limit: Float::INFINITY.to_i, filters: filters, sort: options[:sort])
        records
      end

      def set_csv_response_headers(app, slug)
        filename = "#{slug}-#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
        app.response["Content-Type"] = "text/csv; charset=utf-8"
        app.response["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      end

      def prepare_filters(fields, params, options)
        filter_config = (options[:filters] || []).map { _1.is_a?(Hash) ? _1 : { field: _1 } }
        filter_map = filter_config.to_h { |f| [f[:field], f] }
        values = params["q"] || {}
        fields.each_with_object({}) do |(name, field), result|
          result[field] = { value: values[name], filter: filter_map[name] } if filter_map.key?(name)
        end
      end

      def build_csv(records, fields, repository, fields_options)
        CSV.generate(headers: true) do |csv|
          csv << fields.values.map { |f| f.options[:header] || f.title }

          records.each do |record|
            attrs = repository.index_record_attrs(record, fields: fields_options)
            row = fields.keys.map { |key| attrs[key]&.to_s }
            csv << row
          end
        end
      end
    end
  end
end
