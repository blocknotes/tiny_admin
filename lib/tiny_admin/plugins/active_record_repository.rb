# frozen_string_literal: true

module TinyAdmin
  module Plugins
    class ActiveRecordRepository < BaseRepository
      def index_record_attrs(record, fields: nil)
        return record.attributes.transform_values(&:to_s) if !fields || fields.empty?

        record.attributes.slice(*fields.keys).each_with_object({}) do |(key, value), result|
          field_data = fields[key]
          result[key] =
            if field_data[:converter] && field_data[:method]
              converter = Object.const_get(field_data[:converter])
              converter.send(field_data[:method], value)
            else
              value&.to_s
            end
        end
      end

      def index_title
        title = model.to_s
        title.respond_to?(:pluralize) ? title.pluralize : title
      end

      def fields(options: nil)
        opts = options || {}
        columns = model.columns
        if !opts.empty?
          extra_fields = opts.keys - model.column_names
          raise "Some requested fields are not available: #{extra_fields.join(', ')}" if extra_fields.any?

          columns = opts.keys.map { |field| columns.find { _1.name == field } }
        end
        columns.map do |column|
          name = column.name
          type = opts.dig(column.name, :type) || column.type
          TinyAdmin::Field.create_field(name: name, title: name.humanize, type: type, options: opts[name])
        end
      end

      def show_record_attrs(record, fields: nil)
        attrs = !fields || fields.empty? ? record.attributes : record.attributes.slice(*fields.keys)
        attrs.transform_values(&:to_s)
      end

      def show_title(record)
        "#{model} ##{record.id}"
      end

      def find(reference)
        model.find(reference)
      rescue ActiveRecord::RecordNotFound => e
        raise BaseRepository::RecordNotFound, e.message
      end

      def list(page: 1, limit: 10, filters: nil, sort: ['id'])
        page_offset = page.positive? ? (page - 1) * limit : 0
        query = model.all.order(sort)
        query = apply_filters(query, filters) if filters
        records = query.offset(page_offset).limit(limit).to_a
        [records, query.count]
      end

      def apply_filters(query, filters)
        filters.each do |field, filter|
          value = filter&.dig(:value)
          next if value.nil? || value == ''

          query =
            case field.type
            when :string
              value = ActiveRecord::Base.sanitize_sql_like(value.strip)
              query.where("#{field.name} LIKE ?", "%#{value}%")
            else
              query.where(field.name => value)
            end
        end
        query
      end
    end
  end
end
