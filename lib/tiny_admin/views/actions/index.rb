# frozen_string_literal: true

module TinyAdmin
  module Views
    module Actions
      class Index < DefaultLayout
        attr_accessor :actions,
                      :fields,
                      :filters,
                      :links,
                      :pagination_component,
                      :prepare_record,
                      :records,
                      :show_link,
                      :slug,
                      :sort_params

        def view_template
          super do
            div(class: "index") {
              div(class: "row") {
                div(class: "col-4") {
                  h1(class: "title") {
                    title
                  }
                }
                div(class: "col-8") {
                  actions_buttons
                }
              }

              div(class: "row") {
                div_class = filters&.any? ? "col-9" : "col-12"
                div(class: div_class) {
                  table(class: "table") {
                    table_header if fields.any?

                    table_body
                  }

                  render pagination_component if pagination_component
                }

                if filters&.any?
                  div(class: "col-3") {
                    filters_form = TinyAdmin::Views::Components::FiltersForm.new
                    filters_form.update_attributes(section_path: TinyAdmin.route_for(slug), filters: filters)
                    render filters_form
                  }
                end
              }

              context = { slug: slug, records: records, params: params }
              render TinyAdmin::Views::Components::Widgets.new(widgets, context: context)
            }
          end
        end

        private

        def table_header
          thead {
            tr {
              fields.each_value do |field|
                td(class: "field-header-#{field.name} field-header-type-#{field.type}") {
                  render_sortable_header(field)
                }
              end
              td { whitespace }
            }
          }
        end

        def table_body
          tbody {
            records.each_with_index do |record, index|
              tr(class: "row_#{index + 1}") {
                attributes = prepare_record.call(record)
                attributes.each do |key, value|
                  field = fields[key]
                  next unless field

                  td(class: "field-value-#{field.name} field-value-type-#{field.type}") {
                    render TinyAdmin.settings.components[:field_value].new(field, value, record: record)
                  }
                end

                td(class: "actions p-1") {
                  div(class: "btn-group btn-group-sm") {
                    link_class = "btn btn-outline-secondary"
                    if links
                      links.each do |link|
                        whitespace
                        if link == "show"
                          a(href: TinyAdmin.route_for(slug, reference: record.id), class: link_class) {
                            label_for("Show", options: ["actions.index.links.show"])
                          }
                        else
                          a(href: TinyAdmin.route_for(slug, reference: record.id, action: link), class: link_class) {
                            fallback = humanize(link)
                            label_for(fallback, options: ["actions.index.links.#{link}"])
                          }
                        end
                      end
                    else
                      # Only show the default "Show" link when the show action is enabled for this resource
                      if show_link != false
                        a(href: TinyAdmin.route_for(slug, reference: record.id), class: link_class) {
                          label_for("Show", options: ["actions.index.links.show"])
                        }
                      end
                    end
                  }
                }
              }
            end
          }
        end

        def actions_buttons
          buttons = TinyAdmin::Views::Components::ActionsButtons.new
          buttons.update_attributes(actions: actions, slug: slug)
          render buttons
        end

        # Render a column header as a sortable link.
        # Clicking toggles between ASC and DESC; the current sort direction is
        # preserved in the link so the user can always toggle back.
        def render_sortable_header(field)
          label = field.options[:header] || field.title
          current_dir = sort_params.is_a?(Hash) ? sort_params[field.name] : nil
          next_dir = current_dir&.downcase == "asc" ? "desc" : "asc"
          href = "?#{sort_query_string(field.name, next_dir)}"
          indicator = case current_dir&.downcase
                      when "asc"  then " ▲"
                      when "desc" then " ▼"
                      end
          a(href: href, class: "sort-link text-decoration-none text-reset") {
            plain "#{label}#{indicator}"
          }
        end

        # Build a query string that retains existing filter/page params but sets
        # the sort field and direction.
        def sort_query_string(field_name, direction)
          base = params&.except("sort", "p") || {}
          params_to_s(base.merge("sort" => { field_name => direction }))
        end
      end
    end
  end
end
