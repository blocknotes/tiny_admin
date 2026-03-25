# frozen_string_literal: true

module TinyAdmin
  module Views
    module Actions
      class Show < DefaultLayout
        attr_accessor :actions,
                      :fields,
                      :prepare_record,
                      :record,
                      :reference,
                      :slug

        def view_template
          super do
            div(class: "show") {
              div(class: "row") {
                div(class: "col-4") {
                  h1(class: "title") { title }
                }
                div(class: "col-8") {
                  actions_buttons
                }
              }

              prepare_record.call(record).each do |key, value|
                field = fields[key]
                next unless field

                div(class: "field-#{field.name} row lh-lg") {
                  div(class: "field-header col-2") { field.options[:header] || field.title }
                  div(class: "field-value col-10") {
                    render TinyAdmin.settings.components[:field_value].new(field, value, record: record)
                  }
                }
              end

              render TinyAdmin::Views::Components::Widgets.new(widgets)
            }
          end
        end

        private

        def actions_buttons
          buttons = TinyAdmin::Views::Components::ActionsButtons.new
          buttons.update_attributes(actions: actions, slug: slug, reference: reference)
          render buttons
        end
      end
    end
  end
end
