# frozen_string_literal: true

module TinyAdmin
  module Views
    class DefaultLayout < Phlex::HTML
      include Utils

      attr_accessor :context, :messages, :options, :query_string, :title

      def update_attributes(attributes)
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end

      def template(&block)
        @messages ||= {}
        items = options&.include?(:no_menu) ? [] : settings.navbar

        doctype
        html {
          render components[:head].new(title, style_links: style_links, extra_styles: settings.extra_styles)

          body(class: body_class) {
            render components[:navbar].new(current_slug: context&.slug, root: settings.root, items: items)

            main_content {
              render components[:flash].new(messages: messages)
              yield_content(&block)
            }

            render_scripts
          }
        }
      end

      private

      def components
        settings.components
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

      def body_class
        "module-#{self.class.to_s.split('::').last.downcase}"
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

      def render_scripts
        return unless settings.scripts

        settings.scripts.each do |script_attrs|
          script(**script_attrs)
        end
      end
    end
  end
end
