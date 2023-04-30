# frozen_string_literal: true

module TinyAdmin
  module Actions
    class Show < BasicAction
      def call(app:, context:, options:)
        fields_options = attribute_options(options[:attributes])
        repository = context.repository
        record = repository.find(context.reference)
        prepare_record = ->(record_data) { repository.show_record_attrs(record_data, fields: fields_options) }

        prepare_page(Views::Actions::Show, slug: context.slug) do |page|
          page.update_attributes(
            actions: context.actions,
            fields: repository.fields(options: fields_options),
            prepare_record: prepare_record,
            record: record,
            reference: context.reference,
            slug: context.slug,
            title: repository.show_title(record)
          )
        end
      rescue Plugins::BaseRepository::RecordNotFound => _e
        prepare_page(options[:record_not_found_page] || Views::Pages::RecordNotFound)
      end
    end
  end
end
