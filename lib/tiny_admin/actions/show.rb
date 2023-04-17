# frozen_string_literal: true

module TinyAdmin
  module Actions
    class Show < BasicAction
      attr_reader :repository

      def call(app:, context:, options:, actions:)
        @repository = context.repository
        fields_options = attribute_options(options[:attributes])
        record = repository.find(context.reference)

        prepare_page(Views::Actions::Show) do |page|
          page.update_attributes(
            actions: actions,
            fields: repository.fields(options: fields_options),
            prepare_record: ->(record_data) { repository.show_record_attrs(record_data, fields: fields_options) },
            record: record,
            title: repository.show_title(record)
          )
        end
      rescue Plugins::BaseRepository::RecordNotFound => _e
        prepare_page(options[:record_not_found_page] || Views::Pages::RecordNotFound)
      end
    end
  end
end
