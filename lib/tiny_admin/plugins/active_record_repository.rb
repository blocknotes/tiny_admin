# frozen_string_literal: true

module TinyAdmin
  module Plugins
    class ActiveRecordRepository < BaseRepository
      def index_record_attrs(record, fields: nil)
        return record.attributes.transform_values(&:to_s) unless fields

        fields.to_h do |name, field|
          value = record.send(name)
          [name, translate_value(value, field)]
        end
      end

      def index_title
        title = model.to_s
        title.respond_to?(:pluralize) ? title.pluralize : title
      end

      def fields(options: nil)
        if options
          types = model.columns.to_h { [_1.name, _1.type] }
          options.each_with_object({}) do |(name, field_options), result|
            result[name] = TinyAdmin::Field.create_field(name: name, type: types[name], options: field_options)
          end
        else
          model.columns.each_with_object({}) do |column, result|
            result[column.name] = TinyAdmin::Field.create_field(name: column.name, type: column.type)
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

      def list(page: 1, limit: 10, sort: nil, filters: nil)
        query = sort ? model.all.order(sort) : model.all
        query = apply_filters(query, filters) if filters
        page_offset = page.positive? ? (page - 1) * limit : 0
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
