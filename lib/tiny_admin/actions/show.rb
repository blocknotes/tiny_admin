# frozen_string_literal: true

module TinyAdmin
  module Actions
    class Show < BasicAction
      def call(app:, context:, options:, actions:)
        fields_options = (options[:attributes] || []).each_with_object({}) do |field, result|
          result.merge!(field.is_a?(Hash) ? { field[:field] => field } : { field => { field: field } })
        end
        record = repository.find(context.reference)
        prepare_record = ->(record_data) { repository.show_record_attrs(record_data, fields: fields_options) }
        fields = repository.fields(options: fields_options)

        prepare_page(Views::Actions::Show, title: repository.show_title(record), context: context) do |page|
          page.setup_record(record: record, fields: fields, prepare_record: prepare_record)
          page.actions = actions
        end
      rescue Plugins::BaseRepository::RecordNotFound => _e
        prepare_page(options[:record_not_found_page] || Views::Pages::RecordNotFound)
      end
    end
  end
end
