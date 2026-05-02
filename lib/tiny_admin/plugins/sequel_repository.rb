# frozen_string_literal: true

module TinyAdmin
  module Plugins
    # SequelRepository implements the BaseRepository contract for Sequel datasets.
    #
    # Usage in config:
    #
    #   sections:
    #     - slug: posts
    #       name: Posts
    #       type: resource
    #       model: Post                                   # a Sequel::Model subclass
    #       repository: TinyAdmin::Plugins::SequelRepository
    #
    # Requires the +sequel+ gem.
    class SequelRepository < BaseRepository
      def index_record_attrs(record, fields: nil)
        return record.values.transform_values(&:to_s) unless fields

        fields.to_h { [_1, record.send(_1)] }
      end

      def index_title
        title = model.to_s
        title.respond_to?(:pluralize) ? title.pluralize : title
      end

      # Build Field objects from the model's schema.
      def fields(options: nil)
        schema_types = model.db_schema.to_h { |col, info| [col.to_s, sequel_type_to_sym(info[:type])] }

        if options
          options.to_h do |name, field_options|
            [name, TinyAdmin::Field.create_field(name: name, type: schema_types[name.to_s], options: field_options)]
          end
        else
          schema_types.to_h do |name, type|
            [name, TinyAdmin::Field.create_field(name: name, type: type)]
          end
        end
      end

      alias show_record_attrs index_record_attrs

      def show_title(record)
        "#{model} ##{record.pk}"
      end

      def find(reference)
        model[reference] || raise(BaseRepository::RecordNotFound, "#{model} with pk=#{reference} not found")
      end

      def collection
        model.dataset
      end

      def list(page: 1, limit: 10, sort: nil, filters: nil)
        query = sort ? collection.order(*Array(sort).map { Sequel.lit(_1) }) : collection
        query = apply_filters(query, filters) if filters
        records = query.offset(page_offset(page, limit)).limit(limit).all
        [records, query.count]
      end

      def apply_filters(query, filters)
        filters.reduce(query) do |q, (field, filter)|
          apply_single_filter(q, field, filter)
        end
      end

      private

      def apply_single_filter(query, field, filter)
        value = filter&.dig(:value)
        return query if value.nil? || value == ""

        if value.is_a?(Hash)
          apply_hash_filter(query, field, value)
        elsif value.is_a?(Array)
          non_empty = value.reject { |v| v.to_s.empty? }
          non_empty.any? ? query.where(Sequel[field.name.to_sym] => non_empty) : query
        else
          apply_scalar_filter(query, field, value)
        end
      end

      # Map Sequel schema type symbols to the TinyAdmin field type convention.
      def sequel_type_to_sym(type)
        case type
        when :integer, :bigint, :smallint then :integer
        when :boolean then :boolean
        when :date then :date
        when :datetime, :timestamp then :datetime
        when :float, :decimal, :numeric then :float
        else :string
        end
      end

      def apply_hash_filter(query, field, value)
        gte = value["gte"] || value[:gte]
        lte = value["lte"] || value[:lte]
        col = Sequel[field.name.to_sym]
        query = query.where(col >= gte) if gte && gte != ""
        query = query.where(col <= lte) if lte && lte != ""
        query
      end

      def apply_scalar_filter(query, field, value)
        col = Sequel[field.name.to_sym]
        case field.type
        when :string
          query.where(Sequel.ilike(col, "%#{value.strip}%"))
        else
          query.where(col => value)
        end
      end
    end
  end
end
