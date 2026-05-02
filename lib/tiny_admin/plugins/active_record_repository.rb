# frozen_string_literal: true

module TinyAdmin
  module Plugins
    class ActiveRecordRepository < BaseRepository
      def index_record_attrs(record, fields: nil)
        return record.attributes.transform_values(&:to_s) unless fields

        fields.to_h { [_1, record.send(_1)] }
      end

      def index_title
        title = model.to_s
        title.respond_to?(:pluralize) ? title.pluralize : title
      end

      def fields(options: nil)
        if options
          types = model.columns.to_h { [_1.name, _1.type] }
          options.to_h do |name, field_options|
            [name, TinyAdmin::Field.create_field(name: name, type: types[name], options: field_options)]
          end
        else
          model.columns.to_h do |column|
            [column.name, TinyAdmin::Field.create_field(name: column.name, type: column.type)]
          end
        end
      end

      alias show_record_attrs index_record_attrs

      def show_title(record)
        "#{model} ##{record.id}"
      end

      def find(reference)
        model.find(reference)
      rescue ActiveRecord::RecordNotFound => e
        raise BaseRepository::RecordNotFound, e.message
      end

      def collection
        model.all
      end

      def list(page: 1, limit: 10, sort: nil, filters: nil)
        query = sort ? collection.order(sort) : collection
        query = apply_filters(query, filters) if filters
        records = query.offset(page_offset(page, limit)).limit(limit).to_a
        [records, query.count]
      end

      def apply_filters(query, filters)
        filters.each do |field, filter|
          value = filter&.dig(:value)
          next if value.nil? || value == ""

          query =
            if value.is_a?(Hash)
              apply_hash_filter(query, field, value)
            elsif value.is_a?(Array)
              non_empty = value.reject { |v| v.to_s.empty? }
              next if non_empty.empty?

              query.where(field.name => non_empty)
            else
              apply_scalar_filter(query, field, value)
            end
        end
        query
      end

      private

      # Handle range filters: { "gte" => min, "lte" => max }
      def apply_hash_filter(query, field, value)
        gte = value["gte"] || value[:gte]
        lte = value["lte"] || value[:lte]
        query = query.where("#{field.name} >= ?", gte) if gte.present?
        query = query.where("#{field.name} <= ?", lte) if lte.present?
        query
      end

      # Handle scalar (single-value) filters.
      def apply_scalar_filter(query, field, value)
        case field.type
        when :string
          sanitized = ActiveRecord::Base.sanitize_sql_like(value.strip)
          query.where("#{field.name} LIKE ?", "%#{sanitized}%")
        else
          query.where(field.name => value)
        end
      end
    end
  end
end
