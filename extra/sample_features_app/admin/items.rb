# frozen_string_literal: true

module Admin
  COLUMNS = %i[id first_col second_col third_col].freeze

  Column = Struct.new(:name, :title, :type, :options)
  Item = Struct.new(*COLUMNS)

  RECORDS = [
    Item.new(1, 'value a1', 'value a2', 'value a3'),
    Item.new(2, 'value b1', 'value b2', 'value b3'),
    Item.new(3, 'value c1', 'value c2', 'value c3')
  ].freeze

  class ItemsRepo < TinyAdmin::Plugins::BaseRepository
    def fields(options: nil)
      COLUMNS.map do |name|
        Column.new(name, name.to_s.tr('_', ' '), :string, {})
      end
    end

    def index_record_attrs(record, fields: nil)
      record.to_h
    end

    def index_title
      "Items"
    end

    def list(page: 1, limit: 10, filters: nil, sort: ['id'])
      [
        RECORDS,
        RECORDS.size
      ]
    end

    # ---

    def find(reference)
      RECORDS.find { _1.id == reference.to_i } || raise(TinyAdmin::Plugins::BaseRepository::RecordNotFound)
    end

    def show_record_attrs(record, fields: nil)
      record.to_h
    end

    def show_title(_record)
      "Item"
    end
  end
end

TinyAdmin.configure do |settings|
  (settings.sections ||= []).push(
    slug: 'items',
    name: 'Items',
    type: :resource,
    model: Admin::Item,
    repository: Admin::ItemsRepo
  )
end
