# frozen_string_literal: true

module TinyAdmin
  module Plugins
    # BaseRepository is the contract that every repository plugin must satisfy.
    #
    # Required methods (must be overridden in subclasses):
    #
    #   fields(options: nil) -> Hash<String, TinyAdmin::Field>
    #     Return a hash mapping field name strings to TinyAdmin::Field instances.
    #     When +options+ is provided it should be a hash of field_name => config
    #     and only those fields should be returned.
    #
    #   index_record_attrs(record, fields: nil) -> Hash<String, Object>
    #     Return a hash of attribute values for the given record suitable for
    #     display in the index (collection) view.  When +fields+ is nil, return
    #     all attributes; otherwise only the specified fields.
    #
    #   show_record_attrs(record, fields: nil) -> Hash<String, Object>
    #     Same as index_record_attrs but used in the detail (show) view.
    #
    #   index_title -> String
    #     Return the human-readable title for the collection page.
    #
    #   show_title(record) -> String
    #     Return the human-readable title for the detail page of the given record.
    #
    #   find(reference) -> Object
    #     Find and return the record identified by +reference+ (usually a primary
    #     key string from the URL).  Raise BaseRepository::RecordNotFound when no
    #     record is found.
    #
    #   collection -> Enumerable
    #     Return a "base scope" representing all records of the resource.
    #
    #   list(page: 1, limit: 10, sort: nil, filters: nil) -> [Array, Integer]
    #     Return a two-element array: the page of records and the total count.
    #     +sort+ may be nil, a String/Array accepted by the underlying ORM, or any
    #     structure the concrete repository understands.
    #     +filters+ is a Hash<TinyAdmin::Field, { value: Object, filter: Hash }>
    #     as built by Actions::Index#prepare_filters.
    #
    class BaseRepository
      class RecordNotFound < StandardError
      end

      attr_reader :model

      def initialize(model)
        @model = model
      end

      protected

      # Shared helper: compute the zero-based offset for a given page / limit.
      def page_offset(page, limit)
        page.positive? ? (page - 1) * limit : 0
      end
    end
  end
end
