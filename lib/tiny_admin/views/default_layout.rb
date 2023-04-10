# frozen_string_literal: true

module TinyAdmin
  module Views
    class DefaultLayout < BasicLayout
      attr_accessor :context, :messages, :options, :title

      def template(&block)
        doctype
        html {
          render components[:head].new(title, style_links: style_links, extra_styles: settings.extra_styles)

          body(class: body_class) {
            navbar_attrs = {
              current_slug: context&.slug,
              root_path: settings.root_path,
              root_title: settings.root[:title],
              items: navbar_items
            }
            render components[:navbar].new(**navbar_attrs)

            main_content {
              render components[:flash].new(messages: messages || {})
              yield_content(&block)
            }

            render_scripts
          }
        }
      end

      private

      def body_class
        "module-#{self.class.to_s.split('::').last.downcase}"
      end

      def navbar_items
        options&.include?(:no_menu) ? [] : settings.navbar
      end

      def main_content
        div(class: 'container main-content py-4') do
          if options&.include?(:compact_layout)
            div(class: 'row justify-content-center') {
              div(class: 'col-6') {
                yield
              }
            }
          else
            yield
          end
        end
      end

      def style_links
        settings.style_links || [
          # Bootstrap CDN
          {
            href: 'https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css',
            rel: 'stylesheet',
            integrity: 'sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65',
            crossorigin: 'anonymous'
          }
        ]
      end

      def render_scripts
        (settings.scripts || []).each do |script_attrs|
          script(**script_attrs)
        end
      end
    end
  end
end
