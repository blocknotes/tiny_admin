# frozen_string_literal: true

module Admin
  COLUMNS = %i[id name full_address phone_number].freeze

  Column = Struct.new(:name, :title, :type, :options)
  Item = Struct.new(*COLUMNS)

  RECORDS = 1.upto(100).map do |i|
    Item.new(i, Faker::Name.name, Faker::Address.full_address, Faker::PhoneNumber.phone_number)
  end

  class ItemsRepo < ::TinyAdmin::Plugins::BaseRepository
    def fields(options: nil)
      COLUMNS.each_with_object({}) do |name, result|
        result[name] = TinyAdmin::Field.create_field(name: name)
      end
    end

    def index_record_attrs(record, fields: nil)
      record.to_h
    end

    def index_title
      "Items"
    end

    def list(page: 1, limit: 10, filters: nil, sort: ['id'])
      page_offset = page.positive? ? (page - 1) * limit : 0
      [
        RECORDS[page_offset...page_offset + limit],
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

  module ItemSection
    def to_h
      {
        slug: 'items',
        name: 'Items',
        type: :resource,
        model: Item,
        repository: ItemsRepo
      }
    end

    module_function :to_h
  end
end

TinyAdmin.configure do |settings|
  (settings.sections ||= []).push(Admin::ItemSection)
end
