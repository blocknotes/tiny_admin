# frozen_string_literal: true

module TinyAdmin
  module Actions
    class Show < BasicAction
      def call(app:, context:, options:, actions:)
        fields_options = attribute_options(options[:attributes])
        record = repository.find(context.reference)
        prepare_record = ->(record_data) { repository.show_record_attrs(record_data, fields: fields_options) }
        fields = repository.fields(options: fields_options)

        prepare_page(Views::Actions::Show) do |page|
          page.setup_record(record: record, fields: fields, prepare_record: prepare_record)
          page.update_attributes(actions: actions, title: repository.show_title(record))
        end
      rescue Plugins::BaseRepository::RecordNotFound => _e
        prepare_page(options[:record_not_found_page] || Views::Pages::RecordNotFound)
      end
    end
  end
end
