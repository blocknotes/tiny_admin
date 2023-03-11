# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class Head < Phlex::HTML
        attr_reader :extra_styles, :page_title, :style_links

        def initialize(page_title, style_links: [], extra_styles: nil)
          @page_title = page_title
          @style_links = style_links
          @extra_styles = extra_styles
        end

        def template
          head {
            meta charset: 'utf-8'
            meta name: 'viewport', content: 'width=device-width, initial-scale=1'
            title {
              page_title
            }
            style_links.each do |style_link|
              link(**style_link)
            end
            style { extra_styles } if extra_styles
          }
        end
      end
    end
  end
end
