# frozen_string_literal: true

module TinyAdmin
  module Views
    class DefaultLayout < BasicLayout
      attr_accessor :flash_component, :head_component, :messages, :navbar_component, :options, :title

      def template(&block)
        extra_styles = TinyAdmin.settings.extra_styles
        flash_component&.messages = messages
        head_component&.update_attributes(page_title: title, style_links: style_links, extra_styles: extra_styles)

        doctype
        html {
          render head_component if head_component

          body(class: body_class) {
            render navbar_component if navbar_component

            main_content {
              render flash_component if flash_component

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
        TinyAdmin.settings.style_links || [
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
        (TinyAdmin.settings.scripts || []).each do |script_attrs|
          script(**script_attrs)
        end
      end
    end
  end
end
